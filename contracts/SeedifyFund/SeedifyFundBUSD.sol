/*
 *Seedify.fund
 *Decentralized Incubator
 *A disruptive blockchain incubator program / decentralized seed stage fund, empowered through DAO based community-involvement mechanisms
 */
pragma solidity 0.6.12;

// SPDX-License-Identifier: MIT

import "../ERC20/IERC20.sol";
import "../Ownable/Ownable.sol";
import "../Pausable/Pausable.sol";
import "../ERC20/SafeERC20.sol";
import "../dependencies/ReentrancyGuard.sol";

//SeedifyFundBUSD
contract SeedifyFundBUSD is Ownable, Pausable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    //token attributes
    string public constant NAME = "Seedify.funds.BUSD"; //name of the contract
    uint256 public immutable maxCap; // Max cap in BUSD
    uint256 public immutable saleStartTime; // start sale time
    uint256 public immutable saleEndTime; // end sale time
    uint256 public totalBUSDReceivedInAllTiers; // total bnd received
    // tier -> total_amount
    mapping(uint256 => uint256) public totalBUSDInTiers;
    uint256 public totalparticipants; // total participants in ido
    address payable public immutable projectOwner; // project Owner

    // max cap per tier
    // tier -> max_cap
    mapping(uint256 => uint256) public tierMaxCaps;

    //total users per tier
    // tier -> total_user_count
    mapping(uint256 => uint256) public totalUserInTiers;

    //max allocations per user in a tier
    // tier -> max_allocation_per_user
    mapping(uint256 => uint256) public maxAllocaPerUserTiers;

    //min allocation per user in a tier
    // tier -> min_allocation_per_user
    mapping(uint256 => uint256) public minAllocaPerUserTiers;

    // whitelisted addresses
    // tier -> list of address
    mapping(uint256 => address[]) private whitelistTiers;

    IERC20 public immutable ERC20Interface;
    // address public immutable tokenAddress;

    //mapping the user purchase per tier
    // user -> tier -> amount
    mapping(address => mapping(uint256 => uint256)) public buyInTiers;

    // NOTE: Here, this `struct` could be used like `mapping(address => RefundVault[]) refundInTier1`
    // But, then the `claimRefund` function would be costly as array costs more than mapping in terms of gas during iteration.
    // So, it's dropped as of now.
    // struct RefundVault {
    //     uint256 buyAmount;
    //     uint256 buyTimestamp;
    // }

    uint32 private constant refundDuration = 86400; // 24hr
    uint32 private listingTimestamp; // listing timestamp is taken for a

    // refund amount per user in each tier
    // buyer -> tier -> refund_amount
    mapping(address => mapping(uint256 => uint256)) private refundinTiers;

    // total refund amount per user in all tiers
    // buyer -> total_refund_amount
    mapping(address => uint256) private refundinAllTiers;

    // // buyer -> tier -> refund_timestamp[]
    // NOTE: get it from event filtering
    // mapping(address => mapping(uint256 => uint256[]))
    //     private refundTstampsInTiers;

    // EVENTS
    event TokenBought(
        address indexed buyer,
        uint256 indexed tier,
        uint256 indexed boughtTimestamp,
        uint256 buyAmt
    );
    event RefundClaimed(
        address indexed buyer,
        uint256 indexed tier,
        uint256 indexed refundTimestamp,
        uint256 claimAmt
    );

    // CONSTRUCTOR
    // MC: Max Cap
    constructor(
        uint256 _maxCap,
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        address payable _projectOwner,
        uint256 _tier1MCValue,
        uint256 _tier2MCValue,
        uint256 _tier3MCValue,
        uint256 _tier4MCValue,
        uint256 _tier5MCValue,
        uint256 _tier6MCValue,
        uint256 _tier7MCValue,
        uint256 _tier8MCValue,
        uint256 _tier9MCValue,
        uint256 _totalparticipants,
        address _tokenAddress,
        uint32 _listingTimestamp
    ) public Ownable() Pausable() {
        maxCap = _maxCap;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;

        projectOwner = _projectOwner;

        tierMaxCaps[1] = _tier1MCValue;
        tierMaxCaps[2] = _tier2MCValue;
        tierMaxCaps[3] = _tier3MCValue;
        tierMaxCaps[4] = _tier4MCValue;
        tierMaxCaps[5] = _tier5MCValue;
        tierMaxCaps[6] = _tier6MCValue;
        tierMaxCaps[7] = _tier7MCValue;
        tierMaxCaps[8] = _tier8MCValue;
        tierMaxCaps[9] = _tier9MCValue;

        minAllocaPerUserTiers[1] = 10000000000000;
        minAllocaPerUserTiers[2] = 20000000000000;
        minAllocaPerUserTiers[3] = 30000000000000;
        minAllocaPerUserTiers[4] = 40000000000000;
        minAllocaPerUserTiers[5] = 50000000000000;
        minAllocaPerUserTiers[6] = 60000000000000;
        minAllocaPerUserTiers[7] = 70000000000000;
        minAllocaPerUserTiers[8] = 80000000000000;
        minAllocaPerUserTiers[9] = 90000000000000;

        // TODO: confirm the no.
        totalUserInTiers[1] = 2;
        totalUserInTiers[2] = 2;
        totalUserInTiers[3] = 2;
        totalUserInTiers[4] = 2;
        totalUserInTiers[5] = 2;
        totalUserInTiers[6] = 2;
        totalUserInTiers[7] = 2;
        totalUserInTiers[8] = 2;
        totalUserInTiers[9] = 2;

        // TODO: check for division with local variable
        maxAllocaPerUserTiers[1] = tierMaxCaps[1] / totalUserInTiers[1];
        maxAllocaPerUserTiers[2] = tierMaxCaps[2] / totalUserInTiers[2];
        maxAllocaPerUserTiers[3] = tierMaxCaps[3] / totalUserInTiers[3];
        maxAllocaPerUserTiers[4] = tierMaxCaps[4] / totalUserInTiers[4];
        maxAllocaPerUserTiers[5] = tierMaxCaps[5] / totalUserInTiers[5];
        maxAllocaPerUserTiers[6] = tierMaxCaps[6] / totalUserInTiers[6];
        maxAllocaPerUserTiers[7] = tierMaxCaps[7] / totalUserInTiers[7];
        maxAllocaPerUserTiers[8] = tierMaxCaps[8] / totalUserInTiers[8];
        maxAllocaPerUserTiers[9] = tierMaxCaps[9] / totalUserInTiers[9];

        // TODO: it has to be updated when whitelisted
        totalparticipants = _totalparticipants;

        require(_tokenAddress != address(0), "Zero token address"); //Adding token to the contract
        // tokenAddress = _tokenAddress;
        ERC20Interface = IERC20(_tokenAddress);
        listingTimestamp = _listingTimestamp;
    }

    // function to update the tiers value manually
    function updateTierValues(
        uint256 _tier1MCValue,
        uint256 _tier2MCValue,
        uint256 _tier3MCValue,
        uint256 _tier4MCValue,
        uint256 _tier5MCValue,
        uint256 _tier6MCValue,
        uint256 _tier7MCValue,
        uint256 _tier8MCValue,
        uint256 _tier9MCValue
    ) external onlyOwner whenNotPaused {
        tierMaxCaps[1] = _tier1MCValue;
        tierMaxCaps[2] = _tier2MCValue;
        tierMaxCaps[3] = _tier3MCValue;
        tierMaxCaps[4] = _tier4MCValue;
        tierMaxCaps[5] = _tier5MCValue;
        tierMaxCaps[6] = _tier6MCValue;
        tierMaxCaps[7] = _tier7MCValue;
        tierMaxCaps[8] = _tier8MCValue;
        tierMaxCaps[9] = _tier9MCValue;

        maxAllocaPerUserTiers[1] = _tier1MCValue / totalUserInTiers[1];
        maxAllocaPerUserTiers[2] = _tier2MCValue / totalUserInTiers[2];
        maxAllocaPerUserTiers[3] = _tier3MCValue / totalUserInTiers[3];
        maxAllocaPerUserTiers[4] = _tier4MCValue / totalUserInTiers[4];
        maxAllocaPerUserTiers[5] = _tier5MCValue / totalUserInTiers[5];
        maxAllocaPerUserTiers[6] = _tier6MCValue / totalUserInTiers[6];
        maxAllocaPerUserTiers[7] = _tier7MCValue / totalUserInTiers[7];
        maxAllocaPerUserTiers[8] = _tier9MCValue / totalUserInTiers[8];
        maxAllocaPerUserTiers[9] = _tier9MCValue / totalUserInTiers[9];
    }

    // function to update the tiers users value manually
    function updateTierUsersValue(
        uint256 _tier1UsersValue,
        uint256 _tier2UsersValue,
        uint256 _tier3UsersValue,
        uint256 _tier4UsersValue,
        uint256 _tier5UsersValue,
        uint256 _tier6UsersValue,
        uint256 _tier7UsersValue,
        uint256 _tier8UsersValue,
        uint256 _tier9UsersValue
    ) external onlyOwner whenNotPaused {
        totalUserInTiers[1] = _tier1UsersValue;
        totalUserInTiers[2] = _tier2UsersValue;
        totalUserInTiers[3] = _tier3UsersValue;
        totalUserInTiers[4] = _tier4UsersValue;
        totalUserInTiers[5] = _tier5UsersValue;
        totalUserInTiers[6] = _tier6UsersValue;
        totalUserInTiers[7] = _tier7UsersValue;
        totalUserInTiers[8] = _tier8UsersValue;
        totalUserInTiers[9] = _tier9UsersValue;

        maxAllocaPerUserTiers[1] = tierMaxCaps[1] / _tier1UsersValue;
        maxAllocaPerUserTiers[2] = tierMaxCaps[2] / _tier2UsersValue;
        maxAllocaPerUserTiers[3] = tierMaxCaps[3] / _tier3UsersValue;
        maxAllocaPerUserTiers[4] = tierMaxCaps[4] / _tier4UsersValue;
        maxAllocaPerUserTiers[5] = tierMaxCaps[5] / _tier5UsersValue;
        maxAllocaPerUserTiers[6] = tierMaxCaps[6] / _tier6UsersValue;
        maxAllocaPerUserTiers[7] = tierMaxCaps[7] / _tier7UsersValue;
        maxAllocaPerUserTiers[8] = tierMaxCaps[8] / _tier8UsersValue;
        maxAllocaPerUserTiers[9] = tierMaxCaps[9] / _tier9UsersValue;
    }

    // instead of having multiple functions for each tier.
    // Now, parse the tier along with address
    function addWhitelist(address _address, uint256 _tier)
        external
        onlyOwner
        whenNotPaused
    {
        require(_address != address(0), "Invalid address");
        whitelistTiers[_tier].push(_address);
    }

    function setListingTimestamp(uint32 _listingTstamp) external onlyOwner {
        listingTimestamp = _listingTstamp;
    }

    // instead of having multiple functions for each tier.
    // Now, parse the tier along with address
    function getWhitelist(uint256 _tier, address _address)
        public
        view
        returns (bool)
    {
        uint256 len = whitelistTiers[_tier].length;
        address[] memory whitelistArr = whitelistTiers[_tier];
        for (uint256 i = 0; i < len; i++) {
            address _addressArr = whitelistArr[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    modifier _hasAllowance(address allower, uint256 _amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        require(_amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }

    function buyTokens(uint256 _amount)
        external
        _hasAllowance(msg.sender, _amount)
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(
            now >= saleStartTime && now <= saleEndTime,
            "buyTokens: The sale is either not yet started or is closed now"
        );
        require(
            totalBUSDReceivedInAllTiers + _amount <= maxCap,
            "buyTokens: purchase would exceed max cap"
        );

        uint256 _amountBoughtUser;
        uint256 _totalBUSDinTier;
        address _projOwner = projectOwner;
        uint256 _tier;

        if (getWhitelist(1, msg.sender)) {
            // read the _amount bought by user
            _amountBoughtUser = buyInTiers[msg.sender][1];
            _totalBUSDinTier = totalBUSDInTiers[1];
            require(
                _amountBoughtUser >= minAllocaPerUserTiers[1],
                "buyTokens: your purchasing power is below min. cap"
            );
            require(
                _totalBUSDinTier + _amount <= tierMaxCaps[1],
                "buyTokens: purchase would exceed Tier one max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTiers[1],
                "buyTokens:You are investing more than your tier-1 limit!"
            );

            _tier = 1;
            buyInTiers[msg.sender][1] += _amount;
            totalBUSDReceivedInAllTiers += _amount;
            totalBUSDInTiers[1] += _amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, _amount); //changes to transfer BUSD to owner
            emit TokenBought(msg.sender, _tier, block.timestamp, _amount);
        } else if (getWhitelist(2, msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTiers[msg.sender][2];
            _totalBUSDinTier = totalBUSDInTiers[2];
            require(
                _amountBoughtUser >= minAllocaPerUserTiers[2],
                "buyTokens: your purchasing power is below min. cap"
            );
            require(
                _totalBUSDinTier + _amount <= tierMaxCaps[2],
                "buyTokens: purchase would exceed Tier two max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTiers[2],
                "buyTokens:You are investing more than your tier-2 limit!"
            );

            _tier = 2;
            buyInTiers[msg.sender][2] += _amount;
            totalBUSDReceivedInAllTiers += _amount;
            totalBUSDInTiers[2] += _amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, _amount); //changes to transfer BUSD to owner
            emit TokenBought(msg.sender, _tier, block.timestamp, _amount);
        } else if (getWhitelist(3, msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTiers[msg.sender][3];
            _totalBUSDinTier = totalBUSDInTiers[3];
            require(
                _amountBoughtUser >= minAllocaPerUserTiers[3],
                "buyTokens: your purchasing power is below min. cap"
            );
            require(
                _totalBUSDinTier + _amount <= tierMaxCaps[3],
                "buyTokens: purchase would exceed Tier three max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTiers[3],
                "buyTokens:You are investing more than your tier-3 limit!"
            );

            _tier = 3;
            buyInTiers[msg.sender][3] += _amount;
            totalBUSDReceivedInAllTiers += _amount;
            totalBUSDInTiers[3] += _amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, _amount); //changes to transfer BUSD to owner
            emit TokenBought(msg.sender, _tier, block.timestamp, _amount);
        } else if (getWhitelist(4, msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTiers[msg.sender][4];
            _totalBUSDinTier = totalBUSDInTiers[4];
            require(
                _amountBoughtUser >= minAllocaPerUserTiers[4],
                "buyTokens: your purchasing power is below min. cap"
            );
            require(
                _totalBUSDinTier + _amount <= tierMaxCaps[4],
                "buyTokens: purchase would exceed Tier four max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTiers[4],
                "buyTokens:You are investing more than your tier-4 limit!"
            );

            _tier = 4;
            buyInTiers[msg.sender][4] += _amount;
            totalBUSDReceivedInAllTiers += _amount;
            totalBUSDInTiers[4] += _amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, _amount); //changes to transfer BUSD to owner
            emit TokenBought(msg.sender, _tier, block.timestamp, _amount);
        } else if (getWhitelist(5, msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTiers[msg.sender][5];
            _totalBUSDinTier = totalBUSDInTiers[5];
            require(
                _amountBoughtUser >= minAllocaPerUserTiers[5],
                "buyTokens: your purchasing power is below min. cap"
            );
            require(
                _totalBUSDinTier + _amount <= tierMaxCaps[5],
                "buyTokens: purchase would exceed Tier five max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTiers[5],
                "buyTokens:You are investing more than your tier-5 limit!"
            );

            _tier = 5;
            buyInTiers[msg.sender][5] += _amount;
            totalBUSDReceivedInAllTiers += _amount;
            totalBUSDInTiers[5] += _amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, _amount); //changes to transfer BUSD to owner
            emit TokenBought(msg.sender, _tier, block.timestamp, _amount);
        } else if (getWhitelist(6, msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTiers[msg.sender][6];
            _totalBUSDinTier = totalBUSDInTiers[6];
            require(
                _amountBoughtUser >= minAllocaPerUserTiers[6],
                "buyTokens: your purchasing power is below min. cap"
            );
            require(
                _totalBUSDinTier + _amount <= tierMaxCaps[6],
                "buyTokens: purchase would exceed Tier six max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTiers[6],
                "buyTokens:You are investing more than your tier-6 limit!"
            );

            _tier = 6;
            buyInTiers[msg.sender][6] += _amount;
            totalBUSDReceivedInAllTiers += _amount;
            totalBUSDInTiers[6] += _amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, _amount); //changes to transfer BUSD to owner
            emit TokenBought(msg.sender, _tier, block.timestamp, _amount);
        } else if (getWhitelist(7, msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTiers[msg.sender][7];
            _totalBUSDinTier = totalBUSDInTiers[7];
            require(
                _amountBoughtUser >= minAllocaPerUserTiers[7],
                "buyTokens: your purchasing power is below min. cap"
            );
            require(
                _totalBUSDinTier + _amount <= tierMaxCaps[7],
                "buyTokens: purchase would exceed Tier seven max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTiers[7],
                "buyTokens:You are investing more than your tier-7 limit!"
            );

            _tier = 7;
            buyInTiers[msg.sender][7] += _amount;
            totalBUSDReceivedInAllTiers += _amount;
            totalBUSDInTiers[7] += _amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, _amount); //changes to transfer BUSD to owner
            emit TokenBought(msg.sender, _tier, block.timestamp, _amount);
        } else if (getWhitelist(8, msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTiers[msg.sender][8];
            _totalBUSDinTier = totalBUSDInTiers[8];
            require(
                _amountBoughtUser >= minAllocaPerUserTiers[8],
                "buyTokens: your purchasing power is below min. cap"
            );
            require(
                _totalBUSDinTier + _amount <= tierMaxCaps[8],
                "buyTokens: purchase would exceed Tier eight max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTiers[8],
                "buyTokens:You are investing more than your tier-8 limit!"
            );

            _tier = 8;
            buyInTiers[msg.sender][8] += _amount;
            totalBUSDReceivedInAllTiers += _amount;
            totalBUSDInTiers[8] += _amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, _amount); //changes to transfer BUSD to owner
            emit TokenBought(msg.sender, _tier, block.timestamp, _amount);
        } else if (getWhitelist(9, msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTiers[msg.sender][9];
            _totalBUSDinTier = totalBUSDInTiers[9];
            require(
                _amountBoughtUser >= minAllocaPerUserTiers[9],
                "buyTokens: your purchasing power is below min. cap"
            );
            require(
                _totalBUSDinTier + _amount <= tierMaxCaps[9],
                "buyTokens: purchase would exceed Tier nine max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTiers[9],
                "buyTokens:You are investing more than your tier-9 limit!"
            );

            _tier = 9;
            buyInTiers[msg.sender][9] += _amount;
            totalBUSDReceivedInAllTiers += _amount;
            totalBUSDInTiers[9] += _amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, _amount); //changes to transfer BUSD to owner
            emit TokenBought(msg.sender, _tier, block.timestamp, _amount);
        } else {
            revert("Not whitelisted");
        }
        return true;
    }

    /* 
        TODO:
        - check if the claimer doesn't have gone through 1st vesting
        - check if the bought NFT is still owned
    */
    function claimRefund(uint256 _amount)
        external
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(
            block.timestamp - listingTimestamp <= refundDuration,
            "claimRefund: time limit exceeded"
        );

        if (getWhitelist(1, msg.sender)) {
            uint256 _boughtAmt = buyInTiers[msg.sender][1];

            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");

            // reduce the bought balance of caller
            buyInTiers[msg.sender][1] -= _amount;

            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTiers -= _amount;

            // reduce the total bought balance in this tier
            totalBUSDInTiers[1] -= _amount;

            // Add refund amount for claimer in each tier
            refundinTiers[msg.sender][1] += _amount;

            // Add refund amount for claimer in all tiers
            refundinAllTiers[msg.sender] += _amount;

            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, block.timestamp, _amount);

            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist(2, msg.sender)) {
            uint256 _boughtAmt = buyInTiers[msg.sender][2];

            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");

            // reduce the bought balance of caller
            buyInTiers[msg.sender][2] -= _amount;

            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTiers -= _amount;

            // reduce the total bought balance in this tier
            totalBUSDInTiers[2] -= _amount;

            // Add refund amount for claimer in each tier
            refundinTiers[msg.sender][2] += _amount;

            // Add refund amount for claimer in all tiers
            refundinAllTiers[msg.sender] += _amount;

            // refund claimed event fired
            emit RefundClaimed(msg.sender, 2, block.timestamp, _amount);

            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist(3, msg.sender)) {
            uint256 _boughtAmt = buyInTiers[msg.sender][3];

            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");

            // reduce the bought balance of caller
            buyInTiers[msg.sender][3] -= _amount;

            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTiers -= _amount;

            // reduce the total bought balance in this tier
            totalBUSDInTiers[3] -= _amount;

            // Add refund amount for claimer in each tier
            refundinTiers[msg.sender][3] += _amount;

            // Add refund amount for claimer in all tiers
            refundinAllTiers[msg.sender] += _amount;

            // refund claimed event fired
            emit RefundClaimed(msg.sender, 3, block.timestamp, _amount);

            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist(4, msg.sender)) {
            uint256 _boughtAmt = buyInTiers[msg.sender][4];

            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");

            // reduce the bought balance of caller
            buyInTiers[msg.sender][4] -= _amount;

            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTiers -= _amount;

            // reduce the total bought balance in this tier
            totalBUSDInTiers[4] -= _amount;

            // Add refund amount for claimer in each tier
            refundinTiers[msg.sender][4] += _amount;

            // Add refund amount for claimer in all tiers
            refundinAllTiers[msg.sender] += _amount;

            // refund claimed event fired
            emit RefundClaimed(msg.sender, 4, block.timestamp, _amount);

            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist(5, msg.sender)) {
            uint256 _boughtAmt = buyInTiers[msg.sender][5];

            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");

            // reduce the bought balance of caller
            buyInTiers[msg.sender][5] -= _amount;

            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTiers -= _amount;

            // reduce the total bought balance in this tier
            totalBUSDInTiers[5] -= _amount;

            // Add refund amount for claimer in each tier
            refundinTiers[msg.sender][5] += _amount;

            // Add refund amount for claimer in all tiers
            refundinAllTiers[msg.sender] += _amount;

            // refund claimed event fired
            emit RefundClaimed(msg.sender, 5, block.timestamp, _amount);

            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist(6, msg.sender)) {
            uint256 _boughtAmt = buyInTiers[msg.sender][6];

            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");

            // reduce the bought balance of caller
            buyInTiers[msg.sender][6] -= _amount;

            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTiers -= _amount;

            // reduce the total bought balance in this tier
            totalBUSDInTiers[6] -= _amount;

            // Add refund amount for claimer in each tier
            refundinTiers[msg.sender][6] += _amount;

            // Add refund amount for claimer in all tiers
            refundinAllTiers[msg.sender] += _amount;

            // refund claimed event fired
            emit RefundClaimed(msg.sender, 6, block.timestamp, _amount);

            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist(7, msg.sender)) {
            uint256 _boughtAmt = buyInTiers[msg.sender][7];

            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");

            // reduce the bought balance of caller
            buyInTiers[msg.sender][7] -= _amount;

            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTiers -= _amount;

            // reduce the total bought balance in this tier
            totalBUSDInTiers[7] -= _amount;

            // Add refund amount for claimer in each tier
            refundinTiers[msg.sender][7] += _amount;

            // Add refund amount for claimer in all tiers
            refundinAllTiers[msg.sender] += _amount;

            // refund claimed event fired
            emit RefundClaimed(msg.sender, 7, block.timestamp, _amount);

            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist(8, msg.sender)) {
            uint256 _boughtAmt = buyInTiers[msg.sender][8];

            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");

            // reduce the bought balance of caller
            buyInTiers[msg.sender][8] -= _amount;

            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTiers -= _amount;

            // reduce the total bought balance in this tier
            totalBUSDInTiers[8] -= _amount;

            // Add refund amount for claimer in each tier
            refundinTiers[msg.sender][8] += _amount;

            // Add refund amount for claimer in all tiers
            refundinAllTiers[msg.sender] += _amount;

            // refund claimed event fired
            emit RefundClaimed(msg.sender, 8, block.timestamp, _amount);

            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist(9, msg.sender)) {
            uint256 _boughtAmt = buyInTiers[msg.sender][9];

            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");

            // reduce the bought balance of caller
            buyInTiers[msg.sender][9] -= _amount;

            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTiers -= _amount;

            // reduce the total bought balance in this tier
            totalBUSDInTiers[9] -= _amount;

            // Add refund amount for claimer in each tier
            refundinTiers[msg.sender][9] += _amount;

            // Add refund amount for claimer in all tiers
            refundinAllTiers[msg.sender] += _amount;

            // refund claimed event fired
            emit RefundClaimed(msg.sender, 9, block.timestamp, _amount);

            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else {
            revert("Not whitelisted");
        }

        return false;
    }
}
