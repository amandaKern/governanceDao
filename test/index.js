const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DAO", function () {
  let dao, owner, member1, member2;
  const proposalTitle = "New Proposal";
  const proposalDescription = "This is a new proposal";
  const accept = 0;

  beforeEach(async function () {
    [owner, member1, member2] = await ethers.getSigners();

    const PironToken = await ethers.getContractFactory("GovernanceToken");
    const pironToken = await PironToken.connect(owner).deploy();
    await pironToken.deployed();
    console.log("Piron Token deployed to:", pironToken.address);
    pironToken.transfer(member1.address, 1000);
    pironToken.transfer(member2.address, 1000);
    console.log("Piron Token transferred to:", member1.address);

    const PironDao = await ethers.getContractFactory("DAO");
    dao = await PironDao.connect(owner).deploy(pironToken.address);
    await dao.deployed();
  });

  it("should create a new proposal", async function () {
    await dao
      .connect(member1)
      .createProposal(proposalTitle, proposalDescription);

    const proposals = await dao.getProposals();
    expect(proposals.length).to.equal(1);
    expect(proposals[0].title).to.equal(proposalTitle);
  });

  it("should vote on a proposal", async function () {
    await dao
      .connect(member1)
      .createProposal(proposalTitle, proposalDescription);

    const proposals = await dao.getProposals();
    const proposalId = proposals[0].id;
    console.log("Proposal ID:", proposalId);
    await dao.connect(member2).voteProposal(proposalId, accept);

    const proposal = await dao.getProposalById(proposalId);
    expect(Number(proposal.accept)).to.equal(2);
  });

  it("should execute a proposal", async function () {
    await dao
      .connect(member1)
      .createProposal(proposalTitle, proposalDescription);

    const proposals = await dao.getProposals();
    const proposalId = proposals[0].id;
    await dao.connect(member2).voteProposal(proposalId, accept);

    const proposal = await dao.getProposalById(proposalId);
    expect(proposal.accept).to.equal(2);
    expect(proposal.reject).to.equal(0);
    expect(proposal.abstain).to.equal(0);

    await dao.connect(owner).executeProposal(proposalId);
    expect(await dao.isMember(member2.address)).to.equal(true);
  });
});
