// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

contract FarmToTheMoon is Ownable {
    struct StakerStruct {
        uint256 index;
        uint256 uniqueStakedTokenCound;
        mapping(address => uint256) stakedBalance;
    }

    string public name = "Improved MOON Farm";
    IERC20 public szatkToken;

    mapping(address => address) public tokenPriceFeedMapping;
    address[] public allovedTokens;

    mapping(address => StakerStruct) public stakerStruct;
    address[] public stakerIndex;

    event LogNewStaker(
        address indexed stakerAddress,
        uint256 index,
        uint256 uniqueTokenCount
    );
    event LogUpdateStaker(
        address indexed stakerAddress,
        uint256 index,
        uint256 uniqueTokenCount
    );
    event LogDeleteStaker(address indexed stakerAddress, uint256 index);

    constructor(address _szatk) public {
        szatkToken = IERC20(_szatk);
    }

    //staker managemant
    function isUser(address stakerAddress) public view returns (bool isIndeed) {
        if (stakerIndex.length == 0) return false;
        return (stakerIndex[stakerStruct[stakerAddress].index] ==
            stakerAddress);
    }

    function stake(uint256 _amount, address _token)
        public
        returns (uint256 index)
    {
        require(_amount > 0, "Amount can't be 0.");
        require(tokenIsAlloved(_token), "Token isn't alloved by admin.");

        address staker = msg.sender;
        if (stakerStruct[staker].stakedBalance[_token] == 0) {
            stakerStruct[staker].uniqueStakedTokenCound =
                stakerStruct[staker].uniqueStakedTokenCound +
                1;
        }
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        stakerStruct[staker].stakedBalance[_token] =
            stakerStruct[staker].stakedBalance[_token] +
            _amount;

        if (!isUser(staker)) {
            stakerIndex.push(staker);
            stakerStruct[staker].index = stakerIndex.length - 1;
        }

        emit LogNewStaker(
            staker,
            stakerStruct[staker].index,
            stakerStruct[staker].uniqueStakedTokenCound
        );

        return stakerIndex.length - 1;
    }

    function unstake(address _token) public {
        uint256 balance = stakerStruct[msg.sender].stakedBalance[_token];
        require(balance > 0, "Your staked balance isn't enough.");

        IERC20(_token).transfer(msg.sender, balance);
        stakerStruct[msg.sender].stakedBalance[_token] = 0;
        stakerStruct[msg.sender].uniqueStakedTokenCound =
            stakerStruct[msg.sender].uniqueStakedTokenCound -
            1;

        if (stakerStruct[msg.sender].uniqueStakedTokenCound == 0) {
            deleteStaker(msg.sender);
        }
    }

    function deleteStaker(address stakerAddress)
        private
        returns (uint256 index)
    {
        require(!isUser(stakerAddress), "Staker doesn't exist.");

        uint256 rowToDelete = stakerStruct[stakerAddress].index;
        address keyToMove = stakerIndex[stakerIndex.length - 1];

        stakerIndex[rowToDelete] = keyToMove;
        stakerStruct[keyToMove].index = rowToDelete;
        delete stakerIndex[rowToDelete];
        emit LogDeleteStaker(stakerAddress, rowToDelete);
        emit LogUpdateStaker(
            keyToMove,
            rowToDelete,
            stakerStruct[keyToMove].uniqueStakedTokenCound
        );
        return rowToDelete;
    }

    function getStaker(address staker)
        public
        view
        returns (uint256 index, uint256 uniqueStakedTokenCound)
    {
        require(isUser(staker), "Staker doesn't exist.");
        return (
            stakerStruct[staker].index,
            stakerStruct[staker].uniqueStakedTokenCound
        );
    }

    function getStakerTokens(address staker, address _token)
        public
        view
        returns (address token, uint256 balance)
    {
        require(isUser(staker), "Staker doesn't exist.");
        return (_token, stakerStruct[staker].stakedBalance[_token]);
    }

    function getStakerCount() public view returns (uint256 count) {
        return stakerIndex.length;
    }

    function getUserAtIndex(uint256 index)
        public
        view
        returns (address userAddress)
    {
        return stakerIndex[index];
    }

    // reward managemant
    function sendRewards() public onlyOwner {
        require(getStakerCount() > 0, "There is no stakers.");
        for (uint256 i = 0; i < getStakerCount(); i++) {
            address staker = stakerIndex[i];
            uint256 value = getUserTotalValue(staker);
            szatkToken.transfer(staker, value);
        }
    }

    function getUserTotalValue(address _reciever) public returns (uint256) {
        require(isUser(_reciever), "Staker doesn't exist.");
        uint256 totalValue = 0;
        for (uint256 i = 0; i < allovedTokens.length; i++) {
            totalValue =
                totalValue +
                getTotalTokenValue(allovedTokens[i], _reciever);
        }
        return totalValue;
    }

    function getTotalTokenValue(address _token, address _reciever)
        internal
        view
        returns (uint256)
    {
        if (stakerStruct[_reciever].uniqueStakedTokenCound <= 0) {
            return 0;
        }
        (uint256 price, uint256 decimals) = getTokenPriceData(_token);
        // 10000000000000000000 ETH
        // ETH/USD -> 10000000000
        // 10 * 100 = 1,000
        return ((stakerStruct[_reciever].stakedBalance[_token] * price) /
            (10**decimals));
    }

    function getTokenPriceData(address _token)
        public
        view
        returns (uint256, uint256)
    {
        AggregatorV3Interface price_feed = AggregatorV3Interface(
            tokenPriceFeedMapping[_token]
        );
        (, int256 price, , , ) = price_feed.latestRoundData();
        uint256 priceDecimals = price_feed.decimals();

        return (uint256(price), uint256(priceDecimals));
    }

    // token managemant, price feed
    function addAllovedTokens(address _token) public onlyOwner {
        allovedTokens.push(_token);
    }

    function setPriceFeedAddress(address _token, address _price_feed)
        public
        onlyOwner
    {
        tokenPriceFeedMapping[_token] = _price_feed;
    }

    function tokenIsAlloved(address _token) public view returns (bool) {
        for (uint256 i = 0; i < allovedTokens.length; i++) {
            if (allovedTokens[i] == _token) {
                return true;
            }
        }
        return false;
    }
}