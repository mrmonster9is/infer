// Copyright (c) Facebook, Inc. and its affiliates.
//
// This source code is licensed under the MIT license found in the
// LICENSE file in the root directory of this source tree.

namespace ControlFlow;


function typeCheckDoesntConfuseTheAnalysis_maintainsTaint_Bad(mixed $arg1, SensitiveClass $sc): void {
  if ($arg1 is Foo) {
    \Level1\taintSink($sc);
  }
}

class C {
  public mixed $data;
}

class D {
  public mixed $data;
}

function nullsafeLog(?C $arg): void {
  \Level1\taintSink($arg?->data);
}

function nullsafeAccessTaintedBad(SensitiveClass $sc): void {
  $c = new C();
  $c->data = $sc;
  nullsafeLog($c);
}

function nullsafeAccessNullOk(): void {
  nullsafeLog(null);
}

// Checking handling of `is (non)null

function logWhenNonnull(?mixed $arg): void {
  if ($arg is nonnull) {
    \Level1\taintSink($arg->data);
  }
}

function loggingSensitiveNonnullBad(SensitiveClass $sc): void {
  logWhenNonnull($sc);
}

function loggingSensitiveNonnullCheckedBad(?SensitiveClass $sc): void {
  if ($sc is nonnull) {
    logWhenNonnull($sc);
  }
}

function loggingSensitiveWhenNullOk(?SensitiveClass $sc): void {
  if ($sc is null) {
    logWhenNonnull($sc);
  }
}

// Checking handling of `is <type>` where type is constant

function logWhenSensitive(mixed $arg): void {
  if ($arg is SensitiveClass) {
    \Level1\taintSink($arg);
  }
}

function loggingSensitiveBad(SensitiveClass $sc): void {
  logWhenSensitive($sc);
}

function FN_loggingSensitiveCheckedBad(mixed $arg): void {
  if ($arg is SensitiveClass) {
    logWhenSensitive($arg);
  }
}

function logWhenC(mixed $arg): void {
  if ($arg is C) {
    \Level1\taintSink($arg->data);
  }
}


function loggingSensitiveViaCBad(SensitiveClass $sc, mixed $carrier): void {
  if ($carrier is C) {
    $carrier->data = $sc;
    logWhenC($carrier);
  }
}

function FP_notLoggingSensitiveViaDOk(SensitiveClass $sc, mixed $carrier): void {
  if ($carrier is D) {
    $carrier->data = $sc;
    logWhenC($carrier);
  }
}
