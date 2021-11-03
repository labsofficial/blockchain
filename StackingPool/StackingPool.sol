// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;
 
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
 
        return c;
    }
 
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
 
        return c;
    }
 
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }
 
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
 
        return c;
    }
 
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
 
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
 
        return c;
    }
 
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
 
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Ownable {
  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() public{
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

contract StakingPool is ReentrancyGuard,Ownable{
    using SafeMath for uint256;
    
    uint256 public DAY = 86400;
    // 资金池token
    IERC20 public RECEIVE_TOKEN;
    // 奖励token
    IERC20 public REWARD_TOKEN;

    // 活动开始时间
    uint256 public START_TIMESTAMP;
    // 活动结束时间
    uint256 public END_TIMESTAMP;
    
    // 资金池最大容量
    uint256 public MAX_CAPACITY;
    // 资金池当前金额
    uint256 public CAPITAL_POOL;
    // 分红基数
    uint256 public BASE_REWARD;

    // 用户列表
    address[] public Users;
    // 用户投资金额集合
    mapping(address => uint256) public Deposits;
    // 上次领取奖励时间
    mapping (address=>uint256) public RewardTimes;
    // 撤出投资名单
    mapping(address => bool) public Withdrawed;

    // 每天资金池的总额快照
    mapping(uint256 => uint256) public Capital_Snapshot;

    // 投资事件
    event Deposit(address user,uint256 amount);
    // 提现事件
    event Withdraw(address user,uint256 amount);
    // 领取分红事件
    event Reward(address user,uint256 amount);

    modifier notContract() {
        require(!_isContract(msg.sender), "Contract not allowed");
        require(msg.sender == tx.origin, "Proxy contract not allowed");
        _;
    }

    constructor(address _receive_token,address _reward_token,uint256 _startTime,uint256 _endTime,uint256 _maxCapacity,uint256 _baseReward) public {
        START_TIMESTAMP = _startTime;
        END_TIMESTAMP = _endTime;
        RECEIVE_TOKEN = IERC20(_receive_token);
        REWARD_TOKEN = IERC20(_reward_token);
        MAX_CAPACITY = _maxCapacity;
        BASE_REWARD = _baseReward;
    }

    // 投资 
    function deposit(uint256 _amount) public notContract nonReentrant{
        // 判断活动是否开始
        require(
            now >= START_TIMESTAMP,
            "The event has not yet begun"
        );
        
        // 判断活动是否已结束
        require(
            now <= END_TIMESTAMP,
            "The event is over"
        );
        
        // 判断当前投资金额是否超出资金池最大容量
        require(
            CAPITAL_POOL.add(_amount) <= MAX_CAPACITY,
            "The current investment amount is greater than the maximum prize pool"
        );

        uint256 zerotime = getTimestamp(now);

        if (Deposits[msg.sender] == 0){
            Users.push(msg.sender);
            RewardTimes[msg.sender] = zerotime;
        } 

        uint256 n = getDays(now,RewardTimes[msg.sender]);
        require(
            n == 0,
            "You need a reward before you invest"
        );
        
        require(
            RECEIVE_TOKEN.transferFrom(msg.sender,address(this),_amount),
            "Transfer token to StackingPool failed!"
        );

        Deposits[msg.sender] = Deposits[msg.sender].add(_amount);

        // 更新资金池总量
        CAPITAL_POOL = CAPITAL_POOL.add(_amount);
        // 更新当天快照信息
        Capital_Snapshot[zerotime] = CAPITAL_POOL;
        
        emit Deposit(msg.sender,_amount);
    }

    // 领取分红
    function reward() public notContract nonReentrant{
        require(
            RewardTimes[msg.sender] != 0,
            "You haven't participated in this event"
        );

        require(
            RewardTimes[msg.sender] < END_TIMESTAMP,
            "This event has ended, all dividends have been received"
        );

        uint256 zerotime = getTimestamp(now);
        if (zerotime > END_TIMESTAMP){
            zerotime = END_TIMESTAMP;
        }

        uint256 n = getDays(zerotime,RewardTimes[msg.sender]);
        require(
            n > 0,
            "Did not meet the dividend conditions"
        );

        uint256 amount = 0;
        for(uint i = 1; i <= n; i++){
            uint256 time = zerotime - i.mul(DAY);
            uint256 capital = Capital_Snapshot[time];
            if(capital == 0){
                capital = CAPITAL_POOL;
            }
            uint256 rwa = BASE_REWARD.mul(Deposits[msg.sender]).div(capital);
            amount = amount.add(rwa);
        }

        REWARD_TOKEN.transfer(msg.sender,amount);
        // 更新领取分红时间
        RewardTimes[msg.sender] = zerotime;
        // 更新当天快照信息
        Capital_Snapshot[zerotime] = CAPITAL_POOL;

        emit Reward(msg.sender, amount);
    }

    // 查询可领取分红
    function queryReward(address _user) public view returns(uint256){
        if (RewardTimes[_user] >= END_TIMESTAMP){
            return 0;
        }        

        uint256 zerotime = getTimestamp(now);
        if (zerotime > END_TIMESTAMP){
            zerotime = END_TIMESTAMP;
        }

        uint256 n = getDays(zerotime,RewardTimes[_user]);

        uint256 amount = 0;
        for(uint i = 1; i <= n; i++){
            uint256 time = zerotime - i.mul(DAY);
            uint256 capital = Capital_Snapshot[time];
            if(capital == 0){
                capital = CAPITAL_POOL;
            }
            uint256 rwa = BASE_REWARD.mul(Deposits[_user]).div(capital);
            amount = amount.add(rwa);
        }

        return amount;
    }
    
    // 撤出投资
    function withdraw() public notContract nonReentrant{
        // 判断活动是否已结束
        require(
            now >= END_TIMESTAMP,
            "Token have been locked and can be withdrawn after the event ends"
        );

        // 判断是否已经撤出了所有投资
        require(
            Withdrawed[msg.sender] == false,
            "Has withdrawn all investments"
        );

        uint256 amount = Deposits[msg.sender];
        RECEIVE_TOKEN.transfer(msg.sender, amount);
        Withdrawed[msg.sender] = true;

        emit Withdraw(msg.sender, amount);
    }

    // 根据时间戳间隔天数
    function getDays(uint256 _time,uint256 _baseTime) public view returns(uint256){
        return _time.sub(_baseTime).div(DAY);
    }

    // 获取当日0时时间戳
    function getTimestamp(uint256 _time) public view returns(uint256){
        uint256 n = getDays(_time,START_TIMESTAMP);
        return n.mul(DAY).add(START_TIMESTAMP);
    }
    
    // 获取指定用户的投资情况
    function getUserDeposit(address _user) public view returns(uint256){
        return Deposits[_user];
    }

    // 刷新快照
    function refreshSnapshot() public {
        uint256 zerotime = getTimestamp(now);
        if (zerotime > END_TIMESTAMP){
            zerotime = END_TIMESTAMP;
        }
        Capital_Snapshot[zerotime] = CAPITAL_POOL;
    }

    // 参与活动的用户总数
    function getUserCount() public view returns(uint256){
        return Users.length;
    }

    // 用户投资信息模型
    struct UserDeposit {
        address User;
        uint256 Amount;
    }

    // 根据页数行数获取用户投资数据
    // 返回用户投资信息集合，总用户数，总页数
    function getUsersDepositWithPage(uint256 _page,uint256 _rows) public view returns(UserDeposit[] memory,uint256,uint256){
        uint256 userCount = Users.length;
        uint256 totalPage =  userCount.add(_rows).sub(1).div(_rows);
        
        uint256 startIndex = (_page-1)*_rows;
        uint256 endIndex = _page * _rows;
        if (endIndex > userCount){
            endIndex = userCount;
        }
        
        UserDeposit[] memory users = new UserDeposit[](endIndex.sub(startIndex));
        for(uint i = startIndex ;i < endIndex; i++){
            UserDeposit memory user = UserDeposit({
                User:Users[i],
                Amount:Deposits[Users[i]]
            });
            
            users[i-startIndex] = user;
        }
        
        return (users,userCount,totalPage);
    }
        
    // 投入1个Token获取的奖励Token数量
    // 返回结果需要除以奖励ReceiveToken的decimals（小数位）
    function getDistributionPerToken() public view returns(uint256){
        uint256 decimals = IERC20(RECEIVE_TOKEN).decimals();
        uint256 decimalsValue = 1* (10 ** decimals);
        
        uint256 dividend = BASE_REWARD;
        uint256 divisor = CAPITAL_POOL / decimalsValue;
        return dividend / divisor;
    }
    
    // 用户投资占比模型
    struct UserDistribution {
        address User;
        uint256 Distribution;
    }
    
    // 按页批量查询用户的投资占比，得到的结果需要除以10**10
    function getUserDistributionWithPage(uint256 _page,uint256 _rows) public view returns(UserDistribution[] memory,uint256,uint256){
        uint256 userCount = Users.length;
        uint256 totalPage =  userCount.add(_rows).sub(1).div(_rows);
        
        uint256 startIndex = (_page-1)*_rows;
        uint256 endIndex = _page * _rows;
        if (endIndex > userCount){
            endIndex = userCount;
        }
        
        UserDistribution[] memory users = new UserDistribution[](endIndex.sub(startIndex));
        for(uint i = startIndex ;i < endIndex; i++){
            UserDistribution memory user = UserDistribution({
                User:Users[i],
                Distribution:Deposits[Users[i]].mul(10 ** 10) / CAPITAL_POOL
            });
            
            users[i-startIndex] = user;
        }
        
        return (users,userCount,totalPage);
    }

    /**
     * @notice Check if an address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_addr)
        }
        return size > 0;
    }
    
    // 拒绝ETH转入
    fallback() external{
        revert("Refuse to receive ETH");
    }

    // 销毁合约
    function kill() public onlyOwner{
        selfdestruct(msg.sender);
    }
}