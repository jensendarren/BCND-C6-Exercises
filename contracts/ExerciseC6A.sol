pragma solidity >=0.4.25;

contract ExerciseC6A {

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/
    bool private operational = true;
    uint M = 3;     // number of keys required
    uint N = 5;     // number of keys in total
    address[] store;
    mapping (address => uint) index;

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
    modifier requireContractOwner(){
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

    modifier requireAdmin() {
        require(userProfiles[msg.sender].isAdmin, "User is not an admin and not part of the N key holders");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
     * @dev Allows the contract owner to modify the status
     */
    function setOperatingStatus(bool newOperationalStatus) external requireAdmin {
        // Check the array contains the address already and if not add ti
        addToArray(msg.sender);

        // Now we can use the length property to check we have consenuse
        if(consensusReached()) {
            operational = newOperationalStatus;
        }
    }

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

    function consensusReached() public view returns(bool) {
        return counter() == M;
    }

    function counter() public view returns(uint8) {
        // subtract 1 becuase the array is initialized with one elemetn of address 0
        return uint8(store.length);
    }

    function addToArray(address who) public {
        if (!inArray(who) && who != address(0x0)) {
            // Append
            index[who] = store.length;
            store.push(who);
        }
    }

    function inArray(address who) public view returns (bool) {
        // address 0x0 is not valid if pos is 0 is not in the array
        if (who != address(0x0) && index[who] > 0) {
            return true;
        }
        return false;
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

