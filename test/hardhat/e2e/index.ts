import testEscrow from "./Escrow.test";

function runE2ETests(): void {
  describe("Escrow E2E tests", function () {
    testEscrow();
  });
}

export default runE2ETests;
