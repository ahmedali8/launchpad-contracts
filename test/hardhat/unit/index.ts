import { testEscrow } from "./Escrow.test";

function runUnitTests() {
  describe("Unit tests", function () {
    testEscrow();
  });
}

export default runUnitTests;
