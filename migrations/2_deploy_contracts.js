var education = artifacts.require("./education.sol");

module.exports = function(deployer) {
  deployer.deploy(education);
};
