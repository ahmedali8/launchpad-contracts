import testEscrow from "./Escrow.test";

function runUnitTests(): void {
  describe("Escrow Unit tests", function () {
    testEscrow();
  });
}

export default runUnitTests;
