import flowTest from "./Flow.test";
import MyOAppTest from "./MyOApp.test";
import runUnitTests from "./unit";

describe("Flow tests", function () {
  flowTest();
});

describe("MyOApp tests", function () {
  MyOAppTest();
});

// Runs all unit tests
runUnitTests();
