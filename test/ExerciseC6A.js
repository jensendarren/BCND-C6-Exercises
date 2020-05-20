var Test = require('../config/testConfig.js');
var truffleAssert = require('truffle-assertions');

contract('ExerciseC6A', async (accounts) => {
  var config;

  before('setup contract', async () => {
    config = await Test.Config(accounts);
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

  it('must have a consensus of 3 to change the operational status', async () => {
    let operational = await config.exerciseC6A.isOperational()
    // Contract should start off being operational
    assert.equal(operational, true, 'Error: the contract should be default operational')

    await config.exerciseC6A.setOperatingStatus(false, {from: accounts[1]})
    await config.exerciseC6A.setOperatingStatus(false, {from: accounts[2]})

    operational = await config.exerciseC6A.isOperational()
    // Contract will STILL be operational (since a concensus of 3 requests is required)
    assert.equal(operational, true, 'Error: the contract should be default operational')
  })

  it('should not be possible to modify state when the contract is not operational', async () => {
    let newUser = config.testAddresses[1];

    // set the operational status to false
    await config.exerciseC6A.setOperatingStatus(false, {from: config.owner});
    await config.exerciseC6A.setOperatingStatus(false, {from: accounts[1]});
    await config.exerciseC6A.setOperatingStatus(false, {from: accounts[2]});
    await config.exerciseC6A.setOperatingStatus(false, {from: accounts[3]});

    // now modifing contract state should not be possible
    await truffleAssert.reverts(
      config.exerciseC6A.registerUser(newUser, false, {from: config.owner}),
      "Contract is not operational"
    )
  })

  it('should not be possible to cause a lockout of the contract', async () => {
    // when setting operational to false it should be possible to set it back to true again
    await config.exerciseC6A.setOperatingStatus(false, {from: config.owner});
    await config.exerciseC6A.setOperatingStatus(true, {from: config.owner});
  })

  it('must be an admin to change the operating status', async () => {
    await truffleAssert.reverts(
      config.exerciseC6A.setOperatingStatus(false, {from: accounts[6]}),
      "User is not an admin and not part of the N key holders "
    )
  })

  describe('consensus', () => {
    beforeEach('setup contract', async () => {
      config = await Test.Config(accounts);
    })

    it('ignores repeat function calls by the same administrator', async () => {
      await config.exerciseC6A.setOperatingStatus(false, {from: accounts[1]})
      await config.exerciseC6A.setOperatingStatus(false, {from: accounts[1]})
      await config.exerciseC6A.setOperatingStatus(false, {from: accounts[1]})
      await config.exerciseC6A.setOperatingStatus(false, {from: accounts[1]})
      await config.exerciseC6A.setOperatingStatus(false, {from: accounts[1]})

      let counter = await config.exerciseC6A.counter()
      assert.equal(parseInt(counter), 2, 'Error: Counter is being incremented incorrectly')
    })

    it('updates the operational status when consensus is reached', async () => {
      let operational = await config.exerciseC6A.isOperational()
      // Contract should start off being operational
      assert.equal(operational, true, 'Error: the contract should be default operational')
      await config.exerciseC6A.setOperatingStatus(false, {from: accounts[1]})
      await config.exerciseC6A.setOperatingStatus(false, {from: accounts[2]})
      await config.exerciseC6A.setOperatingStatus(false, {from: accounts[3]})
      operational = await config.exerciseC6A.isOperational()
      let consensusReached = await config.exerciseC6A.consensusReached()
      // Contract will now have an operational status of false since consensus was reached
      assert.equal(consensusReached, true, 'Error: Consensus is not being marked as reached')
      assert.equal(operational, false, 'Error: the contract should NOT be operational')
    })
  })
});
