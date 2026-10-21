/**
 * ShopEase Phase 10C — Security Rules Automated Test Suite
 * 
 * Target: firestore.rules
 * Tooling: @firebase/rules-unit-testing
 * 
 * Prerequisites:
 *   1. Start Firestore Emulator: firebase emulators:start --only firestore
 *   2. Run this test suite: node tests_security/rules.test.js
 */

const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');
const path = require('path');

const PROJECT_ID = 'demo-shopease-rules-test';
const RULES_PATH = path.resolve(__dirname, '..', 'firestore.rules');

let testEnv;

async function setup() {
  const rules = fs.readFileSync(RULES_PATH, 'utf8');
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules,
      host: '127.0.0.1',
      port: 8080,
    },
  });
}

async function runTestSuite() {
  console.log('===============================================================');
  console.log('ShopEase Phase 10C Security Rules Regression Test Suite');
  console.log('===============================================================\n');

  try {
    await setup();
  } catch (err) {
    console.error('FATAL: Could not connect to Firestore Emulator on 127.0.0.1:8080.');
    console.error('Error message:', err.message);
    console.error('\nTo run this test suite:');
    console.error('  1. Start the emulator: firebase emulators:start --only firestore');
    console.error('  2. Run: node tests_security/rules.test.js\n');
    process.exit(1);
  }

  let passed = 0;
  let failed = 0;

  async function test(name, fn) {
    try {
      await fn();
      console.log(`[PASS] ${name}`);
      passed++;
    } catch (err) {
      console.error(`[FAIL] ${name}`);
      console.error(`       Error: ${err.message}`);
      failed++;
    }
  }

  // Pre-seed test data using Admin Context (bypassing rules)
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    
    // Seed legitimate admin profile
    await db.collection('users').doc('admin_uid_123').set({
      uid: 'admin_uid_123',
      name: 'Legitimate Admin',
      email: 'owner@shopease.com',
      role: 'admin',
      phone: '',
      address: '',
      createdAt: new Date(),
    });

    // Seed customer profile
    await db.collection('users').doc('customer_uid_456').set({
      uid: 'customer_uid_456',
      name: 'Customer Jane',
      email: 'jane@example.com',
      role: 'customer',
      phone: '1234567890',
      address: '123 Main St',
      createdAt: new Date(),
    });

    // Seed hostile customer profile who registered with admin@ecommerce.com
    await db.collection('users').doc('hostile_uid_789').set({
      uid: 'hostile_uid_789',
      name: 'Hostile Actor',
      email: 'admin@ecommerce.com',
      role: 'customer',
      phone: '',
      address: '',
      createdAt: new Date(),
    });

    // Seed category
    await db.collection('categories').doc('cat_electronics').set({
      id: 'cat_electronics',
      name: 'Electronics',
      icon: 'devices',
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Seed product
    await db.collection('products').doc('prod_laptop').set({
      id: 'prod_laptop',
      title: 'Pro Laptop',
      description: 'High performance laptop',
      price: 999.99,
      stock: 10,
      categoryId: 'cat_electronics',
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    // Seed customer order
    await db.collection('orders').doc('order_customer_1').set({
      id: 'order_customer_1',
      userId: 'customer_uid_456',
      items: [{ productId: 'prod_laptop', quantity: 1, price: 999.99 }],
      total: 999.99,
      status: 'Pending',
      address: '123 Main St',
      createdAt: new Date(),
      updatedAt: new Date(),
    });
  });

  // Identity Contexts
  const anonymousCtx = testEnv.unauthenticatedContext();
  const customerCtx = testEnv.authenticatedContext('customer_uid_456', { email: 'jane@example.com' });
  const hostileNoDocCtx = testEnv.authenticatedContext('unregistered_hostile_uid', { email: 'admin@ecommerce.com' });
  const hostileCustomerDocCtx = testEnv.authenticatedContext('hostile_uid_789', { email: 'admin@ecommerce.com' });
  const arbitraryUserNoDocCtx = testEnv.authenticatedContext('random_uid_999', { email: 'random@example.com' });
  const legitimateAdminDocCtx = testEnv.authenticatedContext('admin_uid_123', { email: 'owner@shopease.com' });
  const customClaimAdminCtx = testEnv.authenticatedContext('claim_admin_uid', { email: 'claim@shopease.com', admin: true });

  console.log('\n--- NEGATIVE SECURITY TESTS ---');

  await test('SEC-NEG-1: Email admin@ecommerce.com alone with no doc cannot update product', async () => {
    const db = hostileNoDocCtx.firestore();
    await assertFails(db.collection('products').doc('prod_laptop').update({ price: 0.01 }));
  });

  await test('SEC-NEG-2: Email admin@ecommerce.com with customer doc cannot update product', async () => {
    const db = hostileCustomerDocCtx.firestore();
    await assertFails(db.collection('products').doc('prod_laptop').update({ price: 0.01 }));
  });

  await test('SEC-NEG-3: Customer cannot register self with role: admin', async () => {
    const newCtx = testEnv.authenticatedContext('new_attacker_uid', { email: 'attacker@example.com' });
    const db = newCtx.firestore();
    await assertFails(db.collection('users').doc('new_attacker_uid').set({
      uid: 'new_attacker_uid',
      name: 'Attacker',
      email: 'attacker@example.com',
      role: 'admin',
      phone: '',
      address: '',
      createdAt: new Date(),
    }));
  });

  await test('SEC-NEG-4: Customer cannot elevate own role from customer to admin', async () => {
    const db = customerCtx.firestore();
    await assertFails(db.collection('users').doc('customer_uid_456').update({
      role: 'admin',
    }));
  });

  await test('SEC-NEG-5: Customer cannot modify another users profile document', async () => {
    const db = customerCtx.firestore();
    await assertFails(db.collection('users').doc('admin_uid_123').update({
      name: 'Hacked',
    }));
  });

  await test('SEC-NEG-6: Non-admin cannot read another customers order', async () => {
    const db = arbitraryUserNoDocCtx.firestore();
    await assertFails(db.collection('orders').doc('order_customer_1').get());
  });

  await test('SEC-NEG-7: Hostile admin@ecommerce.com customer cannot read another customers order', async () => {
    const db = hostileCustomerDocCtx.firestore();
    await assertFails(db.collection('orders').doc('order_customer_1').get());
  });

  await test('SEC-NEG-8: Non-admin cannot create category', async () => {
    const db = customerCtx.firestore();
    await assertFails(db.collection('categories').doc('cat_hacked').set({
      id: 'cat_hacked',
      name: 'Hacked',
      icon: 'warning',
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  });

  await test('SEC-NEG-9: Non-admin cannot delete product', async () => {
    const db = customerCtx.firestore();
    await assertFails(db.collection('products').doc('prod_laptop').delete());
  });

  await test('SEC-NEG-10: Anonymous visitor cannot create order', async () => {
    const db = anonymousCtx.firestore();
    await assertFails(db.collection('orders').doc('order_anon').set({
      id: 'order_anon',
      userId: 'anonymous_user',
      items: [{ productId: 'prod_laptop', quantity: 1, price: 999.99 }],
      total: 999.99,
      status: 'Pending',
      address: 'Nowhere',
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  });

  console.log('\n--- POSITIVE FUNCTIONAL TESTS ---');

  await test('SEC-POS-1: Anonymous visitor can read public products', async () => {
    const db = anonymousCtx.firestore();
    await assertSucceeds(db.collection('products').doc('prod_laptop').get());
  });

  await test('SEC-POS-2: Anonymous visitor can read public categories', async () => {
    const db = anonymousCtx.firestore();
    await assertSucceeds(db.collection('categories').doc('cat_electronics').get());
  });

  await test('SEC-POS-3: Customer can create valid order for own UID', async () => {
    const db = customerCtx.firestore();
    await assertSucceeds(db.collection('orders').doc('order_customer_new').set({
      id: 'order_customer_new',
      userId: 'customer_uid_456',
      items: [{ productId: 'prod_laptop', quantity: 1, price: 999.99 }],
      total: 999.99,
      status: 'Pending',
      address: '123 Main St',
      createdAt: new Date(),
      updatedAt: new Date(),
    }));
  });

  await test('SEC-POS-4: Customer can read own order', async () => {
    const db = customerCtx.firestore();
    await assertSucceeds(db.collection('orders').doc('order_customer_1').get());
  });

  await test('SEC-POS-5: Customer can update allowed profile fields (name, phone, address)', async () => {
    const db = customerCtx.firestore();
    await assertSucceeds(db.collection('users').doc('customer_uid_456').update({
      name: 'Jane Doe Updated',
      phone: '0987654321',
      address: '456 Oak Ave',
    }));
  });

  await test('SEC-POS-6: Legitimate admin with doc can read all orders', async () => {
    const db = legitimateAdminDocCtx.firestore();
    await assertSucceeds(db.collection('orders').doc('order_customer_1').get());
  });

  await test('SEC-POS-7: Legitimate admin with doc can update order status', async () => {
    const db = legitimateAdminDocCtx.firestore();
    await assertSucceeds(db.collection('orders').doc('order_customer_1').update({
      status: 'Processing',
      updatedAt: new Date(),
    }));
  });

  await test('SEC-POS-8: Custom claims admin can read and manage orders', async () => {
    const db = customClaimAdminCtx.firestore();
    await assertSucceeds(db.collection('orders').doc('order_customer_1').get());
  });

  console.log('\n===============================================================');
  console.log(`Results: ${passed} passed, ${failed} failed out of ${passed + failed} total.`);
  console.log('===============================================================\n');

  await testEnv.cleanup();
}

runTestSuite();
