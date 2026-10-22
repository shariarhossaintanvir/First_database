/**
 * ShopEase Phase 10C.2 — Storage Security Rules Automated Test Suite
 * 
 * Target: storage.rules (with cross-service firestore.rules)
 * Tooling: @firebase/rules-unit-testing
 * 
 * Prerequisites:
 *   Start Emulators: firebase emulators:exec --only firestore,storage "node tests_security/storage.rules.test.js"
 */

const {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} = require('@firebase/rules-unit-testing');
const fs = require('fs');
const path = require('path');

const PROJECT_ID = 'demo-shopease-rules-test';
const FIRESTORE_RULES_PATH = path.resolve(__dirname, '..', 'firestore.rules');
const STORAGE_RULES_PATH = path.resolve(__dirname, '..', 'storage.rules');

let testEnv;

async function setup() {
  const firestoreRules = fs.readFileSync(FIRESTORE_RULES_PATH, 'utf8');
  const storageRules = fs.readFileSync(STORAGE_RULES_PATH, 'utf8');

  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: firestoreRules,
      host: '127.0.0.1',
      port: 8080,
    },
    storage: {
      rules: storageRules,
      host: '127.0.0.1',
      port: 9199,
    },
  });
}

async function runStorageTestSuite() {
  console.log('===============================================================');
  console.log('ShopEase Phase 10C.2 Storage Security Rules Test Suite');
  console.log('===============================================================\n');

  try {
    await setup();
  } catch (err) {
    console.error('FATAL: Could not initialize test environment.');
    console.error('Error message:', err.message);
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

  // Helper buffers
  const smallImageBuffer = Buffer.from('FAKE_IMAGE_DATA_BYTES');
  const zeroByteImageBuffer = Buffer.alloc(0);
  const boundary5MBBuffer = Buffer.alloc(5 * 1024 * 1024); // Exactly 5,242,880 bytes
  const oversizedBuffer = Buffer.alloc((5 * 1024 * 1024) + 1); // 5,242,881 bytes

  // 1. Pre-seed Firestore with user documents (bypassing rules)
  await testEnv.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    
    // Legitimate admin profile
    await db.collection('users').doc('admin_uid_storage').set({
      uid: 'admin_uid_storage',
      name: 'Storage Admin',
      email: 'admin@shopease.com',
      role: 'admin',
      phone: '',
      address: '',
      createdAt: new Date(),
    });

    // Regular customer profile
    await db.collection('users').doc('customer_uid_storage').set({
      uid: 'customer_uid_storage',
      name: 'Storage Customer',
      email: 'customer@example.com',
      role: 'customer',
      phone: '',
      address: '',
      createdAt: new Date(),
    });

    // Hostile customer with admin@ecommerce.com email
    await db.collection('users').doc('hostile_uid_storage').set({
      uid: 'hostile_uid_storage',
      name: 'Hostile Customer',
      email: 'admin@ecommerce.com',
      role: 'customer',
      phone: '',
      address: '',
      createdAt: new Date(),
    });

    // Seed existing files in storage for read/delete tests
    const storage = context.storage();
    await storage.ref('products/existing_prod.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' });
    await storage.ref('product_images/prod_100/existing_sub.png').put(smallImageBuffer, { contentType: 'image/png' });
    await storage.ref('system/config.json').put(Buffer.from('{"secret":"true"}'), { contentType: 'application/json' });
  });

  // Identity contexts
  const anonymousCtx = testEnv.unauthenticatedContext();
  const customerCtx = testEnv.authenticatedContext('customer_uid_storage', { email: 'customer@example.com' });
  const hostileCustomerCtx = testEnv.authenticatedContext('hostile_uid_storage', { email: 'admin@ecommerce.com' });
  const hostileNoDocCtx = testEnv.authenticatedContext('unregistered_hostile_uid', { email: 'admin@ecommerce.com' });
  const unverifiedEmailCtx = testEnv.authenticatedContext('unverified_uid', { email: 'unverified@shopease.com', email_verified: false });
  const noDocUserCtx = testEnv.authenticatedContext('user_without_doc_uid', { email: 'nodoc@example.com' });
  const adminDocCtx = testEnv.authenticatedContext('admin_uid_storage', { email: 'admin@shopease.com' });
  const customClaimAdminCtx = testEnv.authenticatedContext('claim_admin_storage_uid', { email: 'claimadmin@shopease.com', admin: true });

  console.log('--- CATEGORY A: Unauthenticated and Ordinary-User Access ---');

  await test('SEC-STOR-1: Anonymous user cannot upload to /products/', async () => {
    const storage = anonymousCtx.storage();
    await assertFails(storage.ref('products/anon_hack.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-2: Anonymous user cannot upload to /product_images/', async () => {
    const storage = anonymousCtx.storage();
    await assertFails(storage.ref('product_images/prod_1/anon_hack.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-3: Anonymous user cannot delete existing product image', async () => {
    const storage = anonymousCtx.storage();
    await assertFails(storage.ref('products/existing_prod.jpg').delete());
  });

  await test('SEC-STOR-4: Customer cannot upload to /products/', async () => {
    const storage = customerCtx.storage();
    await assertFails(storage.ref('products/cust_upload.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-5: Customer cannot upload to /product_images/', async () => {
    const storage = customerCtx.storage();
    await assertFails(storage.ref('product_images/prod_1/cust_upload.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-6: Customer cannot delete existing product image', async () => {
    const storage = customerCtx.storage();
    await assertFails(storage.ref('products/existing_prod.jpg').delete());
  });

  await test('SEC-STOR-7: Hostile admin@ecommerce.com customer cannot upload to /products/', async () => {
    const storage = hostileCustomerCtx.storage();
    await assertFails(storage.ref('products/hostile_upload.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-8: Unregistered admin@ecommerce.com cannot upload to /products/', async () => {
    const storage = hostileNoDocCtx.storage();
    await assertFails(storage.ref('products/hostile_nodoc.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-9: User with unverified email and no admin role cannot upload', async () => {
    const storage = unverifiedEmailCtx.storage();
    await assertFails(storage.ref('products/unverified.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-10: User with no Firestore doc cannot upload to /products/', async () => {
    const storage = noDocUserCtx.storage();
    await assertFails(storage.ref('products/nodoc.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  console.log('\n--- CATEGORY B: Legitimate Administrator Access ---');

  await test('SEC-STOR-11: Admin (with Firestore doc) can upload valid JPEG to /products/', async () => {
    const storage = adminDocCtx.storage();
    await assertSucceeds(storage.ref('products/admin_valid.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-12: Admin (with Firestore doc) can upload valid PNG to /product_images/', async () => {
    const storage = adminDocCtx.storage();
    await assertSucceeds(storage.ref('product_images/p1/admin_valid.png').put(smallImageBuffer, { contentType: 'image/png' }));
  });

  await test('SEC-STOR-13: Admin (with Firestore doc) can update existing product image', async () => {
    const storage = adminDocCtx.storage();
    await assertSucceeds(storage.ref('products/existing_prod.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-14: Admin (with Firestore doc) can delete existing product image', async () => {
    const storage = adminDocCtx.storage();
    await assertSucceeds(storage.ref('products/existing_prod.jpg').delete());
  });

  await test('SEC-STOR-15: Custom-claim admin ({ admin: true }) can upload valid image', async () => {
    const storage = customClaimAdminCtx.storage();
    await assertSucceeds(storage.ref('products/claim_admin.webp').put(smallImageBuffer, { contentType: 'image/webp' }));
  });

  await test('SEC-STOR-16: Custom-claim admin ({ admin: true }) can delete product image', async () => {
    const storage = customClaimAdminCtx.storage();
    await assertSucceeds(storage.ref('product_images/prod_100/existing_sub.png').delete());
  });

  console.log('\n--- CATEGORY C: File Validation (MIME Types & Size Limits) ---');

  await test('SEC-STOR-17: Admin upload with image/jpeg succeeds', async () => {
    const storage = adminDocCtx.storage();
    await assertSucceeds(storage.ref('products/format_jpeg.jpeg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-18: Admin upload with image/png succeeds', async () => {
    const storage = adminDocCtx.storage();
    await assertSucceeds(storage.ref('products/format_png.png').put(smallImageBuffer, { contentType: 'image/png' }));
  });

  await test('SEC-STOR-19: Admin upload with image/webp succeeds', async () => {
    const storage = adminDocCtx.storage();
    await assertSucceeds(storage.ref('products/format_webp.webp').put(smallImageBuffer, { contentType: 'image/webp' }));
  });

  await test('SEC-STOR-20: Admin upload with image/gif succeeds', async () => {
    const storage = adminDocCtx.storage();
    await assertSucceeds(storage.ref('products/format_gif.gif').put(smallImageBuffer, { contentType: 'image/gif' }));
  });

  await test('SEC-STOR-21: Admin upload with text/plain is denied', async () => {
    const storage = adminDocCtx.storage();
    await assertFails(storage.ref('products/exploit.txt').put(Buffer.from('hello'), { contentType: 'text/plain' }));
  });

  await test('SEC-STOR-22: Admin upload with application/pdf is denied', async () => {
    const storage = adminDocCtx.storage();
    await assertFails(storage.ref('products/doc.pdf').put(Buffer.from('%PDF-1.4'), { contentType: 'application/pdf' }));
  });

  await test('SEC-STOR-23: Admin upload with application/octet-stream is denied', async () => {
    const storage = adminDocCtx.storage();
    await assertFails(storage.ref('products/bin.exe').put(Buffer.from('binary'), { contentType: 'application/octet-stream' }));
  });

  await test('SEC-STOR-24: Admin upload with 0 bytes is denied (size > 0 requirement)', async () => {
    const storage = adminDocCtx.storage();
    await assertFails(storage.ref('products/empty.jpg').put(zeroByteImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-25: Admin upload with oversized file (>5MB) is denied', async () => {
    const storage = adminDocCtx.storage();
    await assertFails(storage.ref('products/huge.jpg').put(oversizedBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-26: Admin upload at exact 5MB boundary succeeds', async () => {
    const storage = adminDocCtx.storage();
    await assertSucceeds(storage.ref('products/boundary_5mb.jpg').put(boundary5MBBuffer, { contentType: 'image/jpeg' }));
  });

  console.log('\n--- CATEGORY D: Path Isolation & Public Read ---');

  await test('SEC-STOR-27: Anonymous user can read (getDownloadURL) public product image in /products/', async () => {
    const storage = anonymousCtx.storage();
    await assertSucceeds(storage.ref('products/format_jpeg.jpeg').getDownloadURL());
  });

  await test('SEC-STOR-28: Anonymous user can read (getDownloadURL) public product image in /product_images/', async () => {
    const storage = anonymousCtx.storage();
    await assertSucceeds(storage.ref('product_images/p1/admin_valid.png').getDownloadURL());
  });

  await test('SEC-STOR-29: Admin cannot upload to non-product path /users/profile.jpg (default deny)', async () => {
    const storage = adminDocCtx.storage();
    await assertFails(storage.ref('users/profile.jpg').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-30: Admin cannot upload to root path /secret.txt (default deny)', async () => {
    const storage = adminDocCtx.storage();
    await assertFails(storage.ref('secret.txt').put(smallImageBuffer, { contentType: 'image/jpeg' }));
  });

  await test('SEC-STOR-31: Anonymous user cannot read from non-product path /system/config.json (default deny)', async () => {
    const storage = anonymousCtx.storage();
    await assertFails(storage.ref('system/config.json').getDownloadURL());
  });

  console.log('\n===============================================================');
  console.log(`Results: ${passed} passed, ${failed} failed out of ${passed + failed} total.`);
  console.log('===============================================================\n');

  await testEnv.cleanup();
}

runStorageTestSuite();
