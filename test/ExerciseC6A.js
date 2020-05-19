var Test = require('../config/testConfig.js');
var truffleAssert = require('truffle-assertions');

contract('ExerciseC6A', async (accounts) => {

  var config;
  var owner;

  before('setup contract', async () => {
    config = await Test.Config(accounts);
    owner = accounts[0]
  });

  it('contract owner can register new user', async () => {

    // ARRANGE
    let caller = accounts[0]; // This should be config.owner or accounts[0] for registering a new user
    let newUser = config.testAddresses[0];

    // ACT
    await config.exerciseC6A.registerUser(newUser, false, {from: caller});
    let result = await config.exerciseC6A.isUserRegistered.call(newUser);

    // ASSERT
    assert.equal(result, true, "Contract owner cannot register new user");

  });

  it('should be possible for the owner to change the operation flag', async () => {
    // the contract should be operational by default
    let operational = await config.exerciseC6A.isOperational()
    assert.equal(operational, true, 'Error: the contract should be default operational')

    // try calling setOperatingStatus and setting operational to false
    await config.exerciseC6A.setOperatingStatus(false, {from: owner});
    operational = await config.exerciseC6A.isOperational()

    assert.equal(operational, false, 'Error: operational flag not updated')
  })

  it('should not be possible to change the operational status of the contract when not the owner', async () => {
    // try calling setOperatingStatus and setting operational to false
    await truffleAssert.reverts(
      config.exerciseC6A.setOperatingStatus(false, {from: accounts[1]}),
      "Caller is not contract owner"
    )
  })

  it('should not be possible to modify state when the contract is not operational', async () => {
    let newUser = config.testAddresses[0];

    // set the operational status to false
    await config.exerciseC6A.setOperatingStatus(false, {from: owner});

    // now modifing contract state should not be possible
    await truffleAssert.reverts(
      config.exerciseC6A.registerUser(newUser, false, {from: owner}),
      "Contract is not operational"
    )
  })
});
