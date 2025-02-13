import runE2ETests from "./e2e";
import runUnitTests from "./unit";

// Runs all unit tests
describe("Unit tests", function () {
  runUnitTests();
});

// Run all end-to-end tests
describe("End-to-End tests", function () {
  runE2ETests();
});
