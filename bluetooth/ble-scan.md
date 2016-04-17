

## 代码流程

**startScan**
```java
BluetoothLeScanner.startScan
BleScanCallbackWrapper.startRegisteration
BleScanCallbackWrapper.onClientRegistered
GattService.startScan
ScanManager.startScan
ScanManager.ClientHandler.handleStartScan
+ RegularScan
+ BatchScan

RegularScan
  ScanNative.startRegularScan
    configureScanFilters
      gattClientScanFilterEnableNative
      configureFilterParamter
        gattClientScanFilterParamAddNative
    gattClientScanNative
  ScanNative.configureRegularScanParams // if it isn't opportunistic scan mode
    gattClientScanNative(false)
    gattSetScanParametersNative
    gattClientScanNative(true)
```

## CTS Test
- https://source.android.com/compatibility/cts/setup.html

```shell
$ cd android-cts/tools
$ ./cts-tradefed
cts-tf > run cts -c android.bluetooth.cts.BluetoothLeScanTest
```

## BluetoothLeScanTest

```java
//@cts/tests/tests/bluetooth/src/android/bluetooth/cts/BluetoothLeScanTest.java

//@testBasicBleScan: 使用low power mode启动BLE搜索
public void testBasicBleScan() {
  if (!isBleSupported()) return;
  long scanStartMillis = SystemClock.elapsedRealtime();
  Collection<ScanResult> scanResults = scan(); // will scan 5s and use low power mode (slow)
  long scanEndMillis = SystemClock.elapsedRealtime();
  assertTrue("Scan results shouldn't be empty", !scanResults.isEmpty());
  verifyTimestamp(scanResults, scanStartMillis, scanEndMillis);
}

//@testBatchScan: 使用batch scan和low latency mode启动BLE搜索
public void testBatchScan() {
  if (!isBleSupported() || !isBleBatchScanSupported()) {
    Log.d(TAG, "BLE or BLE batching not suppported");
    return;
  }
  ScanSettings batchScanSettings = new ScanSettings.Builder()
      .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)         // scan with low latency mode (fast)
      .setReportDelay(BATCH_SCAN_REPORT_DELAY_MILLIS).build(); // will report after 20s if not flush
  BleScanCallback batchScanCallback = new BleScanCallback();
  mScanner.startScan(Collections.<ScanFilter> emptyList(), batchScanSettings,batchScanCallback);
  sleep(SCAN_DURATION_MILLIS);                                 // will scan 5 seconds
  mScanner.flushPendingScanResults(batchScanCallback);
  mFlushBatchScanLatch = new CountDownLatch(1);
  List<ScanResult> results = batchScanCallback.getBatchScanResults();
  try {
    mFlushBatchScanLatch.await(5, TimeUnit.SECONDS);
  } catch (InterruptedException e) {
    // Nothing to do.
    Log.e(TAG, "interrupted!");
  }
  assertTrue(!results.isEmpty());
  long scanEndMillis = SystemClock.elapsedRealtime();
  mScanner.stopScan(batchScanCallback);
  verifyTimestamp(results, 0, scanEndMillis);
}

//@testOpportunisticScan
public void testOpportunisticScan() {
  if (!isBleSupported()) return;
  ScanSettings opportunisticScanSettings = new ScanSettings.Builder()
      .setScanMode(ScanSettings.SCAN_MODE_OPPORTUNISTIC).build();
  BleScanCallback emptyScanCallback = new BleScanCallback();
  //使用opportunistic mode启动搜索并等待5s，单独的opportunistic模式不会真正启动搜索
  mScanner.startScan(Collections.<ScanFilter> emptyList(), opportunisticScanSettings, emptyScanCallback);
  sleep(SCAN_DURATION_MILLIS);
  assertTrue(emptyScanCallback.getScanResults().isEmpty());
  //使用low latency mode以及filter条件再次启动搜索
  BleScanCallback regularScanCallback = new BleScanCallback();
  ScanSettings regularScanSettings = new ScanSettings.Builder()
      .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build();
  List<ScanFilter> filters = new ArrayList<>();
  ScanFilter filter = createScanFilter();
  if (filter != null) {
      filters.add(filter);
  } else {
      Log.d(TAG, "no appropriate filter can be set");
  }
  mScanner.startScan(filters, regularScanSettings, regularScanCallback);
  sleep(SCAN_DURATION_MILLIS);
  // With normal BLE scan client, opportunistic scan client will get scan results.
  assertTrue("opportunistic scan results shouldn't be empty", !emptyScanCallback.getScanResults().isEmpty());
  mScanner.stopScan(regularScanCallback);
  // In case we got scan results before scan was completely stopped.
  sleep(1000);
  emptyScanCallback.clear();
  sleep(SCAN_DURATION_MILLIS);
  assertTrue("opportunistic scan shouldn't have scan results", emptyScanCallback.getScanResults().isEmpty());
}

//@testScanFilter: 使用low latency mode以及filter条件搜索BLE设备
public void testScanFilter() {
  if (!isBleSupported()) return;
  List<ScanFilter> filters = new ArrayList<ScanFilter>();
  ScanFilter filter = createScanFilter();
  if (filter == null) {
      Log.d(TAG, "no appropriate filter can be set");
      return;
  }
  filters.add(filter);
  BleScanCallback filterLeScanCallback = new BleScanCallback();
  ScanSettings settings = new ScanSettings.Builder()
      .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY).build();
  mScanner.startScan(filters, settings, filterLeScanCallback);
  sleep(SCAN_DURATION_MILLIS);
  mScanner.stopScan(filterLeScanCallback);
  sleep(1000);
  Collection<ScanResult> scanResults = filterLeScanCallback.getScanResults();
  for (ScanResult result : scanResults) {
    assertTrue(filter.matches(result));
  }
}

//@createScanFilter: 使用scan()搜索附近的设备，并将信号最强的设备作为filter条件
private ScanFilter createScanFilter() {
  // Get a list of nearby beacons.
  List<ScanResult> scanResults = new ArrayList<ScanResult>(scan());
  assertTrue("Scan results shouldn't be empty", !scanResults.isEmpty());
  // Find the beacon with strongest signal strength, which is the target device for filter scan.
  Collections.sort(scanResults, new RssiComparator());
  ScanResult result = scanResults.get(0);
  ScanRecord record = result.getScanRecord();
  if (record == null) return null;
  Map<ParcelUuid, byte[]> serviceData = record.getServiceData();
  if (serviceData != null && !serviceData.isEmpty()) {
    ParcelUuid uuid = serviceData.keySet().iterator().next();
    return new ScanFilter.Builder().setServiceData(uuid, new byte[] { 0 },
        new byte[] { 0 }).build();
  }
  SparseArray<byte[]> manufacturerSpecificData = record.getManufacturerSpecificData();
  if (manufacturerSpecificData != null && manufacturerSpecificData.size() > 0) {
    return new ScanFilter.Builder().setManufacturerData(manufacturerSpecificData.keyAt(0),
        new byte[] { 0 }, new byte[] { 0 }).build();
  }
  List<ParcelUuid> serviceUuids = record.getServiceUuids();
  if (serviceUuids != null && !serviceUuids.isEmpty()) {
    return new ScanFilter.Builder().setServiceUuid(serviceUuids.get(0)).build();
  }
  return null;
}
```
