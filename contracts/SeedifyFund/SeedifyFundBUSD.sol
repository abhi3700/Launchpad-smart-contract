/*
 *Seedify.fund
 *Decentralized Incubator
 *A disruptive blockchain incubator program / decentralized seed stage fund, empowered through DAO based community-involvement mechanisms
 */
pragma solidity 0.6.12;

// SPDX-License-Identifier: UNLICENSED

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
    uint256 public totalBUSDReceivedInAllTier; // total bnd received
    uint256 public totalBUSDInTier1; // total BUSD for tier one
    uint256 public totalBUSDInTier2; // total BUSD for tier Tier
    uint256 public totalBUSDInTier3; // total BUSD for tier Three
    uint256 public totalBUSDInTier4; // total BUSD for tier Four
    uint256 public totalBUSDInTier5; // total BUSD for tier Five
    uint256 public totalBUSDInTier6; // total BUSD for tier Six
    uint256 public totalBUSDInTier7; // total BUSD for tier Seven
    uint256 public totalBUSDInTier8; // total BUSD for tier Eight
    uint256 public totalBUSDInTier9; // total BUSD for tier Nine
    uint256 public totalparticipants; // total participants in ido
    address payable public immutable projectOwner; // project Owner

    // max cap per tier
    uint256 public tierMaxCap1;
    uint256 public tierMaxCap2;
    uint256 public tierMaxCap3;
    uint256 public tierMaxCap4;
    uint256 public tierMaxCap5;
    uint256 public tierMaxCap6;
    uint256 public tierMaxCap7;
    uint256 public tierMaxCap8;
    uint256 public tierMaxCap9;

    //total users per tier
    uint256 public totalUserInTier1;
    uint256 public totalUserInTier2;
    uint256 public totalUserInTier3;
    uint256 public totalUserInTier4;
    uint256 public totalUserInTier5;
    uint256 public totalUserInTier6;
    uint256 public totalUserInTier7;
    uint256 public totalUserInTier8;
    uint256 public totalUserInTier9;

    //max allocations per user in a tier
    uint256 public maxAllocaPerUserTier1;
    uint256 public maxAllocaPerUserTier2;
    uint256 public maxAllocaPerUserTier3;
    uint256 public maxAllocaPerUserTier4;
    uint256 public maxAllocaPerUserTier5;
    uint256 public maxAllocaPerUserTier6;
    uint256 public maxAllocaPerUserTier7;
    uint256 public maxAllocaPerUserTier8;
    uint256 public maxAllocaPerUserTier9;

    //min allocation per user in a tier
    uint256 public minAllocaPerUserTier1;
    uint256 public minAllocaPerUserTier2;
    uint256 public minAllocaPerUserTier3;
    uint256 public minAllocaPerUserTier4;
    uint256 public minAllocaPerUserTier5;
    uint256 public minAllocaPerUserTier6;
    uint256 public minAllocaPerUserTier7;
    uint256 public minAllocaPerUserTier8;
    uint256 public minAllocaPerUserTier9;

    // address array for tier one whitelist
    address[] private whitelistTier1;

    // address array for tier two whitelist
    address[] private whitelistTier2;

    // address array for tier three whitelist
    address[] private whitelistTier3;

    // address array for tier Four whitelist
    address[] private whitelistTier4;

    // address array for tier three whitelist
    address[] private whitelistTier5;

    // address array for tier three whitelist
    address[] private whitelistTier6;

    // address array for tier three whitelist
    address[] private whitelistTier7;

    // address array for tier three whitelist
    address[] private whitelistTier8;

    // address array for tier three whitelist
    address[] private whitelistTier9;

    IERC20 public immutable ERC20Interface;
    // address public immutable tokenAddress;

    //mapping the user purchase per tier
    mapping(address => uint256) public buyInTier1;
    mapping(address => uint256) public buyInTier2;
    mapping(address => uint256) public buyInTier3;
    mapping(address => uint256) public buyInTier4;
    mapping(address => uint256) public buyInTier5;
    mapping(address => uint256) public buyInTier6;
    mapping(address => uint256) public buyInTier7;
    mapping(address => uint256) public buyInTier8;
    mapping(address => uint256) public buyInTier9;

    // NOTE: Here, this `struct` could be used like `mapping(address => RefundVault[]) refundInTier1`
    // But, then the `claimRefund` function would be costly as array costs more than mapping in terms of gas during iteration.
    // So, it's dropped as of now.
    // struct RefundVault {
    //     uint256 buyAmount;
    //     uint256 buyTimestamp;
    // }

    uint32 private constant refundDuration = 86400; // 24hr
    uint32 private listingTimestamp;

    // buyer -> tier -> timestamp -> amount
    // mapping(address => mapping(uint256 => mapping(uint256 => uint256)))
    //     private refundInTiers;
    // mapping(address => mapping(uint256 => uint256)) private refundInTier2;
    // mapping(address => mapping(uint256 => uint256)) private refundInTier3;
    // mapping(address => mapping(uint256 => uint256)) private refundInTier4;
    // mapping(address => mapping(uint256 => uint256)) private refundInTier5;
    // mapping(address => mapping(uint256 => uint256)) private refundInTier6;
    // mapping(address => mapping(uint256 => uint256)) private refundInTier7;
    // mapping(address => mapping(uint256 => uint256)) private refundInTier8;
    // mapping(address => mapping(uint256 => uint256)) private refundInTier9;

    // buyer -> tier -> timestamp[]
    // mapping(address => mapping(uint256 => uint256[]))
    //     private refundTstampsInTiers;
    // mapping(address => uint256[]) private refundTstampsInTier2;
    // mapping(address => uint256[]) private refundTstampsInTier3;
    // mapping(address => uint256[]) private refundTstampsInTier4;
    // mapping(address => uint256[]) private refundTstampsInTier5;
    // mapping(address => uint256[]) private refundTstampsInTier6;
    // mapping(address => uint256[]) private refundTstampsInTier7;
    // mapping(address => uint256[]) private refundTstampsInTier8;
    // mapping(address => uint256[]) private refundTstampsInTier9;

    // EVENTS
    // TODO: add `TokenBought`
    event RefundClaimed(
        address indexed buyer,
        uint256 indexed tier,
        uint256 claimAmt
    );

    // CONSTRUCTOR
    constructor(
        uint256 _maxCap,
        uint256 _saleStartTime,
        uint256 _saleEndTime,
        address payable _projectOwner,
        uint256 _tier1Value,
        uint256 _tier2Value,
        uint256 _tier3Value,
        uint256 _tier4Value,
        uint256 _tier5Value,
        uint256 _tier6Value,
        uint256 _tier7Value,
        uint256 _tier8Value,
        uint256 _tier9Value,
        uint256 _totalparticipants,
        address _tokenAddress,
        uint32 _listingTimestamp
    ) public Ownable() Pausable() {
        maxCap = _maxCap;
        saleStartTime = _saleStartTime;
        saleEndTime = _saleEndTime;

        projectOwner = _projectOwner;
        tierMaxCap1 = _tier1Value;
        tierMaxCap2 = _tier2Value;
        tierMaxCap3 = _tier3Value;
        tierMaxCap4 = _tier4Value;
        tierMaxCap5 = _tier5Value;
        tierMaxCap6 = _tier6Value;
        tierMaxCap7 = _tier7Value;
        tierMaxCap8 = _tier8Value;
        tierMaxCap9 = _tier9Value;

        minAllocaPerUserTier1 = 10000000000000;
        minAllocaPerUserTier2 = 20000000000000;
        minAllocaPerUserTier3 = 30000000000000;
        minAllocaPerUserTier4 = 40000000000000;
        minAllocaPerUserTier5 = 50000000000000;
        minAllocaPerUserTier6 = 60000000000000;
        minAllocaPerUserTier7 = 70000000000000;
        minAllocaPerUserTier8 = 80000000000000;
        minAllocaPerUserTier9 = 90000000000000;

        totalUserInTier1 = 2;
        totalUserInTier2 = 2;
        totalUserInTier3 = 2;
        totalUserInTier4 = 2;
        totalUserInTier5 = 2;
        totalUserInTier6 = 2;
        totalUserInTier7 = 2;
        totalUserInTier8 = 2;
        totalUserInTier9 = 2;

        maxAllocaPerUserTier1 = tierMaxCap1 / totalUserInTier1;
        maxAllocaPerUserTier2 = tierMaxCap2 / totalUserInTier2;
        maxAllocaPerUserTier3 = tierMaxCap3 / totalUserInTier3;
        maxAllocaPerUserTier4 = tierMaxCap4 / totalUserInTier4;
        maxAllocaPerUserTier5 = tierMaxCap5 / totalUserInTier5;
        maxAllocaPerUserTier6 = tierMaxCap6 / totalUserInTier6;
        maxAllocaPerUserTier7 = tierMaxCap7 / totalUserInTier7;
        maxAllocaPerUserTier8 = tierMaxCap8 / totalUserInTier8;
        maxAllocaPerUserTier9 = tierMaxCap9 / totalUserInTier9;
        totalparticipants = _totalparticipants;
        require(_tokenAddress != address(0), "Zero token address"); //Adding token to the contract
        // tokenAddress = _tokenAddress;
        ERC20Interface = IERC20(_tokenAddress);
        listingTimestamp = _listingTimestamp;
    }

    // function to update the tiers value manually
    function updateTierValues(
        uint256 _tier1Value,
        uint256 _tier2Value,
        uint256 _tier3Value,
        uint256 _tier4Value,
        uint256 _tier5Value,
        uint256 _tier6Value,
        uint256 _tier7Value,
        uint256 _tier8Value,
        uint256 _tier9Value
    ) external onlyOwner whenNotPaused {
        tierMaxCap1 = _tier1Value;
        tierMaxCap2 = _tier2Value;
        tierMaxCap3 = _tier3Value;
        tierMaxCap4 = _tier4Value;
        tierMaxCap5 = _tier5Value;
        tierMaxCap6 = _tier6Value;
        tierMaxCap7 = _tier7Value;
        tierMaxCap8 = _tier8Value;
        tierMaxCap9 = _tier9Value;

        maxAllocaPerUserTier1 = tierMaxCap1 / totalUserInTier1;
        maxAllocaPerUserTier2 = tierMaxCap2 / totalUserInTier2;
        maxAllocaPerUserTier3 = tierMaxCap3 / totalUserInTier3;
        maxAllocaPerUserTier4 = tierMaxCap4 / totalUserInTier4;
        maxAllocaPerUserTier5 = tierMaxCap5 / totalUserInTier5;
        maxAllocaPerUserTier6 = tierMaxCap6 / totalUserInTier6;
        maxAllocaPerUserTier7 = tierMaxCap7 / totalUserInTier7;
        maxAllocaPerUserTier8 = tierMaxCap8 / totalUserInTier8;
        maxAllocaPerUserTier9 = tierMaxCap9 / totalUserInTier9;
    }

    // function to update the tiers users value manually
    function updateTierUsersValue(
        uint256 _tierOneUsersValue,
        uint256 _tierTwoUsersValue,
        uint256 _tierThreeUsersValue,
        uint256 _tierFourUsersValue,
        uint256 _tierFiveUsersValue,
        uint256 _tierSixUsersValue,
        uint256 _tierSevenUsersValue,
        uint256 _tierEightUsersValue,
        uint256 _tierNineUsersValue
    ) external onlyOwner whenNotPaused {
        totalUserInTier1 = _tierOneUsersValue;
        totalUserInTier2 = _tierTwoUsersValue;
        totalUserInTier3 = _tierThreeUsersValue;
        totalUserInTier4 = _tierFourUsersValue;
        totalUserInTier5 = _tierFiveUsersValue;
        totalUserInTier6 = _tierSixUsersValue;
        totalUserInTier7 = _tierSevenUsersValue;
        totalUserInTier8 = _tierEightUsersValue;
        totalUserInTier9 = _tierNineUsersValue;

        maxAllocaPerUserTier1 = tierMaxCap1 / totalUserInTier1;
        maxAllocaPerUserTier2 = tierMaxCap2 / totalUserInTier2;
        maxAllocaPerUserTier3 = tierMaxCap3 / totalUserInTier3;
        maxAllocaPerUserTier4 = tierMaxCap4 / totalUserInTier4;
        maxAllocaPerUserTier5 = tierMaxCap5 / totalUserInTier5;
        maxAllocaPerUserTier6 = tierMaxCap6 / totalUserInTier6;
        maxAllocaPerUserTier7 = tierMaxCap7 / totalUserInTier7;
        maxAllocaPerUserTier8 = tierMaxCap8 / totalUserInTier8;
        maxAllocaPerUserTier9 = tierMaxCap9 / totalUserInTier9;
    }

    //add the address in Whitelist tier One to invest
    function addWhitelist1(address _address) external onlyOwner whenNotPaused {
        require(_address != address(0), "Invalid address");
        whitelistTier1.push(_address);
    }

    //add the address in Whitelist tier two to invest
    function addWhitelist2(address _address) external onlyOwner whenNotPaused {
        require(_address != address(0), "Invalid address");
        whitelistTier2.push(_address);
    }

    //add the address in Whitelist tier three to invest
    function addWhitelist3(address _address) external onlyOwner whenNotPaused {
        require(_address != address(0), "Invalid address");
        whitelistTier3.push(_address);
    }

    //add the address in Whitelist tier Four to invest
    function addWhitelist4(address _address) external onlyOwner whenNotPaused {
        require(_address != address(0), "Invalid address");
        whitelistTier4.push(_address);
    }

    //add the address in Whitelist tier three to invest
    function addWhitelist5(address _address) external onlyOwner whenNotPaused {
        require(_address != address(0), "Invalid address");
        whitelistTier5.push(_address);
    }

    //add the address in Whitelist tier three to invest
    function addWhitelist6(address _address) external onlyOwner whenNotPaused {
        require(_address != address(0), "Invalid address");
        whitelistTier6.push(_address);
    }

    //add the address in Whitelist tier three to invest
    function addWhitelist7(address _address) external onlyOwner whenNotPaused {
        require(_address != address(0), "Invalid address");
        whitelistTier7.push(_address);
    }

    //add the address in Whitelist tier three to invest
    function addWhitelist8(address _address) external onlyOwner whenNotPaused {
        require(_address != address(0), "Invalid address");
        whitelistTier8.push(_address);
    }

    //add the address in Whitelist tier three to invest
    function addWhitelist9(address _address) external onlyOwner whenNotPaused {
        require(_address != address(0), "Invalid address");
        whitelistTier9.push(_address);
    }

    // check the address in whitelist tier one
    function getWhitelist1(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTier1.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelistTier1[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    // check the address in whitelist tier two
    function getWhitelist2(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTier2.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelistTier2[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    // check the address in whitelist tier three
    function getWhitelist3(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTier3.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelistTier3[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    // check the address in whitelist tier Four
    function getWhitelist4(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTier4.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelistTier4[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    // check the address in whitelist tier Five
    function getWhitelist5(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTier5.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelistTier5[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    // check the address in whitelist tier Six
    function getWhitelist6(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTier6.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelistTier6[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    // check the address in whitelist tier Seven
    function getWhitelist7(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTier7.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelistTier7[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    // check the address in whitelist tier Eight
    function getWhitelist8(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTier8.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelistTier8[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    // check the address in whitelist tier Nine
    function getWhitelist9(address _address) public view returns (bool) {
        uint256 i;
        uint256 length = whitelistTier9.length;
        for (i = 0; i < length; i++) {
            address _addressArr = whitelistTier9[i];
            if (_addressArr == _address) {
                return true;
            }
        }
        return false;
    }

    modifier _hasAllowance(address allower, uint256 amount) {
        // Make sure the allower has provided the right allowance.
        // ERC20Interface = IERC20(tokenAddress);
        uint256 ourAllowance = ERC20Interface.allowance(allower, address(this));
        require(amount <= ourAllowance, "Make sure to add enough allowance");
        _;
    }

    function buyTokens(uint256 amount)
        external
        _hasAllowance(msg.sender, amount)
        nonReentrant
        whenNotPaused
        returns (bool)
    {
        require(
            now >= saleStartTime && now <= saleEndTime,
            "buyTokens: The sale is either not yet started or is closed now"
        );
        require(
            totalBUSDReceivedInAllTier + amount <= maxCap,
            "buyTokens: purchase would exceed max cap"
        );

        uint256 _amountBoughtUser = 0;
        uint256 _totalBUSDinTier;
        address _projOwner = projectOwner;

        if (getWhitelist1(msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTier1[msg.sender];
            _totalBUSDinTier = totalBUSDInTier1;
            require(
                _amountBoughtUser >= minAllocaPerUserTier1,
                "your purchasing Power is so Low"
            );
            require(
                _totalBUSDinTier + amount <= tierMaxCap1,
                "buyTokens: purchase would exceed Tier one max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTier1,
                "buyTokens:You are investing more than your tier-1 limit!"
            );

            buyInTier1[msg.sender] += amount;
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTier1 += amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist2(msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTier2[msg.sender];
            _totalBUSDinTier = totalBUSDInTier2;
            require(
                _amountBoughtUser >= minAllocaPerUserTier2,
                "your purchasing Power is so Low"
            );
            require(
                _totalBUSDinTier + amount <= tierMaxCap2,
                "buyTokens: purchase would exceed Tier two max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTier2,
                "buyTokens:You are investing more than your tier-2 limit!"
            );

            buyInTier2[msg.sender] += amount;
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTier2 += amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist3(msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTier3[msg.sender];
            _totalBUSDinTier = totalBUSDInTier3;
            require(
                _amountBoughtUser >= minAllocaPerUserTier3,
                "your purchasing Power is so Low"
            );
            require(
                _totalBUSDinTier + amount <= tierMaxCap3,
                "buyTokens: purchase would exceed Tier three max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTier3,
                "buyTokens:You are investing more than your tier-3 limit!"
            );

            buyInTier3[msg.sender] += amount;
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTier3 += amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist4(msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTier4[msg.sender];
            _totalBUSDinTier = totalBUSDInTier4;
            require(
                _amountBoughtUser >= minAllocaPerUserTier4,
                "your purchasing Power is so Low"
            );
            require(
                _totalBUSDinTier + amount <= tierMaxCap4,
                "buyTokens: purchase would exceed Tier four max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTier4,
                "buyTokens:You are investing more than your tier-4 limit!"
            );

            buyInTier4[msg.sender] += amount;
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTier4 += amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist5(msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTier5[msg.sender];
            _totalBUSDinTier = totalBUSDInTier5;
            require(
                _amountBoughtUser >= minAllocaPerUserTier5,
                "your purchasing Power is so Low"
            );
            require(
                _totalBUSDinTier + amount <= tierMaxCap5,
                "buyTokens: purchase would exceed Tier five max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTier5,
                "buyTokens:You are investing more than your tier-5 limit!"
            );

            buyInTier5[msg.sender] += amount;
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTier5 += amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist6(msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTier6[msg.sender];
            _totalBUSDinTier = totalBUSDInTier6;
            require(
                _amountBoughtUser >= minAllocaPerUserTier6,
                "your purchasing Power is so Low"
            );
            require(
                _totalBUSDinTier + amount <= tierMaxCap6,
                "buyTokens: purchase would exceed Tier six max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTier6,
                "buyTokens:You are investing more than your tier-6 limit!"
            );

            buyInTier6[msg.sender] += amount;
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTier6 += amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist7(msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTier7[msg.sender];
            _totalBUSDinTier = totalBUSDInTier7;
            require(
                _amountBoughtUser >= minAllocaPerUserTier7,
                "your purchasing Power is so Low"
            );
            require(
                _totalBUSDinTier + amount <= tierMaxCap7,
                "buyTokens: purchase would exceed Tier seven max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTier7,
                "buyTokens:You are investing more than your tier-7 limit!"
            );

            buyInTier7[msg.sender] += amount;
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTier7 += amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist8(msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTier8[msg.sender];
            _totalBUSDinTier = totalBUSDInTier8;
            require(
                _amountBoughtUser >= minAllocaPerUserTier8,
                "your purchasing Power is so Low"
            );
            require(
                _totalBUSDinTier + amount <= tierMaxCap8,
                "buyTokens: purchase would exceed Tier eight max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTier8,
                "buyTokens:You are investing more than your tier-8 limit!"
            );

            buyInTier8[msg.sender] += amount;
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTier8 += amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, amount); //changes to transfer BUSD to owner
        } else if (getWhitelist9(msg.sender)) {
            // read the amount bought by user
            _amountBoughtUser = buyInTier9[msg.sender];
            _totalBUSDinTier = totalBUSDInTier9;
            require(
                _amountBoughtUser >= minAllocaPerUserTier9,
                "your purchasing Power is so Low"
            );
            require(
                _totalBUSDinTier + amount <= tierMaxCap9,
                "buyTokens: purchase would exceed Tier nine max cap"
            );
            require(
                _amountBoughtUser <= maxAllocaPerUserTier9,
                "buyTokens:You are investing more than your tier-9 limit!"
            );

            buyInTier9[msg.sender] += amount;
            totalBUSDReceivedInAllTier += amount;
            totalBUSDInTier9 += amount;
            ERC20Interface.safeTransferFrom(msg.sender, _projOwner, amount); //changes to transfer BUSD to owner
        } else {
            revert("Not whitelisted");
        }
        return true;
    }

    function setListingTimestamp(uint32 _listingTstamp) external onlyOwner {
        listingTimestamp = _listingTstamp;
    }

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

        if (getWhitelist1(msg.sender)) {
            uint256 _boughtAmt = buyInTier1[msg.sender];
            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");
            // reduce the bought balance of caller
            buyInTier1[msg.sender] -= _amount;
            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTier -= _amount;
            // reduce the total bought balance in this tier
            totalBUSDInTier1 -= _amount;
            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, _amount);
            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist2(msg.sender)) {
            uint256 _boughtAmt = buyInTier1[msg.sender];
            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");
            // reduce the bought balance of caller
            buyInTier1[msg.sender] -= _amount;
            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTier -= _amount;
            // reduce the total bought balance in this tier
            totalBUSDInTier1 -= _amount;
            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, _amount);
            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist3(msg.sender)) {
            uint256 _boughtAmt = buyInTier3[msg.sender];
            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");
            // reduce the bought balance of caller
            buyInTier3[msg.sender] -= _amount;
            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTier -= _amount;
            // reduce the total bought balance in this tier
            totalBUSDInTier3 -= _amount;
            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, _amount);
            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist4(msg.sender)) {
            uint256 _boughtAmt = buyInTier4[msg.sender];
            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");
            // reduce the bought balance of caller
            buyInTier4[msg.sender] -= _amount;
            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTier -= _amount;
            // reduce the total bought balance in this tier
            totalBUSDInTier4 -= _amount;
            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, _amount);
            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist5(msg.sender)) {
            uint256 _boughtAmt = buyInTier5[msg.sender];
            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");
            // reduce the bought balance of caller
            buyInTier5[msg.sender] -= _amount;
            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTier -= _amount;
            // reduce the total bought balance in this tier
            totalBUSDInTier5 -= _amount;
            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, _amount);
            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist6(msg.sender)) {
            uint256 _boughtAmt = buyInTier6[msg.sender];
            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");
            // reduce the bought balance of caller
            buyInTier6[msg.sender] -= _amount;
            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTier -= _amount;
            // reduce the total bought balance in this tier
            totalBUSDInTier6 -= _amount;
            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, _amount);
            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist7(msg.sender)) {
            uint256 _boughtAmt = buyInTier7[msg.sender];
            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");
            // reduce the bought balance of caller
            buyInTier7[msg.sender] -= _amount;
            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTier -= _amount;
            // reduce the total bought balance in this tier
            totalBUSDInTier7 -= _amount;
            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, _amount);
            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist8(msg.sender)) {
            uint256 _boughtAmt = buyInTier8[msg.sender];
            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");
            // reduce the bought balance of caller
            buyInTier8[msg.sender] -= _amount;
            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTier -= _amount;
            // reduce the total bought balance in this tier
            totalBUSDInTier8 -= _amount;
            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, _amount);
            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else if (getWhitelist9(msg.sender)) {
            uint256 _boughtAmt = buyInTier9[msg.sender];
            require(_boughtAmt > 0, "zero bought amount");
            require(_amount <= _boughtAmt, "claim amount is more than bought");
            // reduce the bought balance of caller
            buyInTier9[msg.sender] -= _amount;
            // reduce the total bought balance in all tiers
            totalBUSDReceivedInAllTier -= _amount;
            // reduce the total bought balance in this tier
            totalBUSDInTier9 -= _amount;
            // refund claimed event fired
            emit RefundClaimed(msg.sender, 1, _amount);
            // refund the bought amount
            ERC20Interface.safeTransfer(msg.sender, _amount);
        } else {
            revert("Not whitelisted");
        }

        return false;
    }
}
