pragma solidity >=0.4.25;

contract ExerciseC6A {

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/
    bool private operational = true;

    struct UserProfile {
        bool isRegistered;
        bool isAdmin;
    }

    address private contractOwner;                  // Account used to deploy contract
    mapping(address => UserProfile) userProfiles;   // Mapping for storing user profiles



    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    // No events

    /**
    * @dev Constructor
    *      The deploying account becomes contractOwner
    */
    constructor() public {
        contractOwner = msg.sender;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
    * @dev Modifier that requires the "ContractOwner" account to be the function caller
    */
    modifier requireContractOwner()
    {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    /**
    * @dev Modifier that checks the contract is operational before allowing state changes
    */
    modifier requireOperational() {
        require(operational, "Contract is not operational");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
     * @dev Allows the contract owner to modify the status
     */
    function setOperatingStatus(bool newOperationalStatus) external requireContractOwner {
        operational = newOperationalStatus;
    }

    /**
    * @dev Sets contract operations on/off
    *
    * When operational mode is disabled, all write transactions except for this one will fail
    */

   /**
    * @dev Check if a user is registered
    *
    * @return A bool that indicates if the user is registered
    */
    function isUserRegistered
                            (
                                address account
                            )
                            external
                            view
                            returns(bool)
    {
        require(account != address(0), "'account' must be a valid address.");
        return userProfiles[account].isRegistered;
    }

    /**
    * @dev Get operating status of contract
    *
    * @return A bool that is the current operating status
    */
    function isOperational() public view returns(bool) {
        return operational;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    function registerUser
                                (
                                    address account,
                                    bool isAdmin
                                )
                                external
                                requireContractOwner
                                requireOperational
    {
        require(!userProfiles[account].isRegistered, "User is already registered.");

        userProfiles[account] = UserProfile({
                                                isRegistered: true,
                                                isAdmin: isAdmin
                                            });
    }
}

