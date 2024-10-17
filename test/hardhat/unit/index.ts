import testEscrow from "./Escrow.test";

function runUnitTests(): void {
  describe("Escrow", function () {
    testEscrow();
  });
}

export default runUnitTests;
