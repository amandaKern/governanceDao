const { ethers } = require("hardhat");

async function main() {
  // Deploy the governance token
  const Token = await ethers.getContractFactory("GovernanceToken");
  const token = await Token.deploy("Piron Coin", "PIC");

  // Deploy the dao
  const Dao = await ethers.getContractFactory("DAO");
  const dao = await Dao.deploy(token.address);

  console.log("Token deployed to:", token.address);
  console.log("Dao deployed to:", dao.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
