pragma solidity >=0.4.26 <0.7.0;

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

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
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

interface IERC1400 {
  // Document Management
  function getDocument(bytes32 _name) external view returns (string memory, bytes32);
  function setDocument(bytes32 _name, string calldata _uri, bytes32 _documentHash) external;

  // Token Information
  function balanceOfByPartition(bytes32 _partition, address _tokenHolder) external view returns (uint256);
  function partitionsOf(address _tokenHolder) external view returns (bytes32[] memory);

  // Transfers
  function transferWithData(address _to, uint256 _value, bytes calldata _data) external;
  function transferFromWithData(address _from, address _to, uint256 _value, bytes calldata _data) external;

  // Partition Token Transfers
  function transferByPartition(bytes32 _partition, address _to, uint256 _value, bytes calldata _data) external returns (bytes32);
  function operatorTransferByPartition(bytes32 _partition, address _from, address _to, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external returns (bytes32);

  // Controller Operation
  function isControllable() external view returns (bool);
  //function controllerTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _operatorData) external;
  //function controllerRedeem(address _tokenHolder, uint256 _value, bytes _data, bytes _operatorData) external;

  // Operator Management
  function authorizeOperator(address _operator) external;
  function revokeOperator(address _operator) external;
  function authorizeOperatorByPartition(bytes32 _partition, address _operator) external;
  function revokeOperatorByPartition(bytes32 _partition, address _operator) external;

  // Operator Information
  function isOperator(address _operator, address _tokenHolder) external view returns (bool);
  function isOperatorForPartition(bytes32 _partition, address _operator, address _tokenHolder) external view returns (bool);

  // Token Issuance
  function isIssuable() external view returns (bool);
  function issue(address _tokenHolder, uint256 _value, bytes calldata _data) external;
  function issueByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes calldata _data) external;

  // Token Redemption
  function redeem(uint256 _value, bytes calldata _data) external;
  function redeemFrom(address _tokenHolder, uint256 _value, bytes calldata _data) external;
  function redeemByPartition(bytes32 _partition, uint256 _value, bytes calldata _data) external;
  function operatorRedeemByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes calldata _operatorData) external;

  // Transfer Validity
  function canTransfer(address _to, uint256 _value, bytes calldata _data) external view returns (byte, bytes32);
  function canTransferFrom(address _from, address _to, uint256 _value, bytes calldata _data) external view returns (byte, bytes32);
  function canTransferByPartition(address _from, address _to, bytes32 _partition, uint256 _value, bytes calldata _data) external view returns (byte, bytes32, bytes32);    

  // Controller Events
  event ControllerTransfer(
      address _controller,
      address indexed _from,
      address indexed _to,
      uint256 _value,
      bytes _data,
      bytes _operatorData
  );

  event ControllerRedemption(
      address _controller,
      address indexed _tokenHolder,
      uint256 _value,
      bytes _data,
      bytes _operatorData
  );

  // Document Events
  event Document(bytes32 indexed _name, string _uri, bytes32 _documentHash);

  // Transfer Events
  event TransferByPartition(
      bytes32 indexed _fromPartition,
      address _operator,
      address indexed _from,
      address indexed _to,
      uint256 _value,
      bytes _data,
      bytes _operatorData
  );

  event ChangedPartition(
      bytes32 indexed _fromPartition,
      bytes32 indexed _toPartition,
      uint256 _value
  );

  // Operator Events
  event AuthorizedOperator(address indexed _operator, address indexed _tokenHolder);
  event RevokedOperator(address indexed _operator, address indexed _tokenHolder);
  event AuthorizedOperatorByPartition(bytes32 indexed _partition, address indexed _operator, address indexed _tokenHolder);
  event RevokedOperatorByPartition(bytes32 indexed _partition, address indexed _operator, address indexed _tokenHolder);

  // Issuance / Redemption Events
  event Issued(address indexed _operator, address indexed _to, uint256 _value, bytes _data);
  event Redeemed(address indexed _operator, address indexed _from, uint256 _value, bytes _data);
  event IssuedByPartition(bytes32 indexed _partition, address indexed _operator, address indexed _to, uint256 _value, bytes _data, bytes _operatorData);
  event RedeemedByPartition(bytes32 indexed _partition, address indexed _operator, address indexed _from, uint256 _value, bytes _operatorData);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract ERC1400 is IERC20,IERC1400,MinterRole,Ownable{
    using SafeMath for uint256;
    
    /*********************************** ERC20 Token Details ****************************************/
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals = 18;// The number of decimals of the token. For retrocompatibility, decimals are forced to 18 in ERC1400.
    uint256 internal _totalSupply;
    /************************************************************************************************/
    
    /********************************** ERC20 Token mappings ****************************************/
    // Mapping from tokenHolder to balance.
    mapping(address => uint256) internal _balances;

    // Mapping from (tokenHolder, spender) to allowed value.
    mapping (address => mapping (address => uint256)) internal _allowed;
    /************************************************************************************************/
    
    
    /**************************************** Documents *********************************************/
    struct Doc {
        string docURI;
        bytes32 docHash;
    }
    // Mapping for token URIs.
    mapping(bytes32 => Doc) internal _documents;
    /************************************************************************************************/

    /**************************************** Token behaviours **************************************/
    // Indicate whether the token can still be controlled by operators or not anymore.
    bool internal _isControllable;
    
    // Indicate whether the token can still be issued by the issuer or not anymore.
    bool internal _isIssuable;
    /************************************************************************************************/

    /*********************************** Partitions  mappings ***************************************/
    // List of partitions.
    bytes32[] internal _totalPartitions;
    
    // Mapping from partition to their index.
    mapping (bytes32 => uint256) internal _indexOfTotalPartitions;
    
    // Mapping from partition to global balance of corresponding partition.
    mapping (bytes32 => uint256) internal _totalSupplyByPartition;
    
    // Mapping from tokenHolder to their partitions.
    mapping (address => bytes32[]) internal _partitionsOf;
    
    // Mapping from (tokenHolder, partition) to their index.
    mapping (address => mapping (bytes32 => uint256)) internal _indexOfPartitionsOf;
    
    // Mapping from (tokenHolder, partition) to balance of corresponding partition.
    mapping (address => mapping (bytes32 => uint256)) internal _balanceOfByPartition;
    
    // List of token default partitions (for ERC20 compatibility).
    bytes32[] internal _defaultPartitions;
    /************************************************************************************************/
    
    /********************************* Global operators mappings ************************************/
    // Mapping from (operator, tokenHolder) to authorized status. [TOKEN-HOLDER-SPECIFIC]
    mapping(address => mapping(address => bool)) internal _authorizedOperator;
    
    // Array of controllers. [GLOBAL - NOT TOKEN-HOLDER-SPECIFIC]
    address[] internal _controllers;
    
    // Mapping from operator to controller status. [GLOBAL - NOT TOKEN-HOLDER-SPECIFIC]
    mapping(address => bool) internal _isController;
    /************************************************************************************************/
    
    /******************************** Partition operators mappings **********************************/
    // Mapping from (partition, tokenHolder, spender) to allowed value. [TOKEN-HOLDER-SPECIFIC]
    mapping(bytes32 => mapping (address => mapping (address => uint256))) internal _allowedByPartition;
    
    // Mapping from (tokenHolder, partition, operator) to 'approved for partition' status. [TOKEN-HOLDER-SPECIFIC]
    mapping (address => mapping (bytes32 => mapping (address => bool))) internal _authorizedOperatorByPartition;
    
    // Mapping from partition to controllers for the partition. [NOT TOKEN-HOLDER-SPECIFIC]
    mapping (bytes32 => address[]) internal _controllersByPartition;
    
    // Mapping from (partition, operator) to PartitionController status. [NOT TOKEN-HOLDER-SPECIFIC]
    mapping (bytes32 => mapping (address => bool)) internal _isControllerByPartition;
    /************************************************************************************************/
    
    /************************************* 准入名单管理 ****************************************/
    //enable allow list controll
    bool internal _allowlistActivated;

    //enable block list controll
    bool internal _blocklistActivated;

    //Mapping from block list
    mapping(address => bool) internal _blocklist;

    //Mapping allow block list
    mapping (address=> bool) internal _allowlist;
    /****************************************************************************************/
    
    /**************************** Events (additional - not mandatory) *******************************/
    event ApprovalByPartition(bytes32 indexed _partition, address indexed _tokenHolder, address indexed _spender, uint256 _value);
    /************************************************************************************************/
    
    /***************************************** Modifiers ********************************************/
    /**
    * @dev Modifier to verify if token is issuable.
    */
    modifier isIssuableToken() {
        require(_isIssuable, "55"); // 0x55	funds locked (lockup period)
        _;
    }
    /************************************************************************************************/
    
    constructor(string memory _tname,string memory _tsymbol,address[] memory _tcontrollers,bytes32[] memory _tdefaultPartitions,bool _tisControllable) public{
        _name = _tname;
        _symbol = _tsymbol;
        _decimals = 18;
        
        _setControllers(_tcontrollers);
        _defaultPartitions =  _tdefaultPartitions;
        
        _isControllable = _tisControllable;
        _isIssuable = true;
    }
    
    
    /****************************** EXTERNAL FUNCTIONS (ERC20 INTERFACE) ****************************/
    function name() public view returns (string memory){
        return _name;
    }
    
    function symbol() public view returns (string memory){
        return _symbol;
    }
    
    function decimals() public view returns (uint8){
        return _decimals;
    }
    
    function totalSupply() external view returns (uint256){
        return _totalSupply;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance){
        return _balances[_owner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success){
        byte arg1;
        bytes32 arg2;
        bytes32 arg3;
        (arg1,arg2,arg3) = _canTransfer(msg.sender,_to,"",_value);

        require(arg1 == hex"00");

        _transferByDefaultPartitions(msg.sender,msg.sender,_to,_value,"");
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require( _isOperator(msg.sender,_from) 
        || (_value <= _allowed[_from][msg.sender]),"53");
        
        if(_allowed[_from][msg.sender] >= _value){
            _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
        }else{
            _allowed[_from][msg.sender] = 0;
        }
        
        byte arg1;
        bytes32 arg2;
        bytes32 arg3;
        (arg1,arg2,arg3) = _canTransfer(_from,_to,"",_value);

        require(arg1 == hex"00");
        
        _transferByDefaultPartitions(msg.sender,_from,_to,_value,"");
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success){
        require(_spender != address(0), "56");
        
        _allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return _allowed[_owner][_spender];
    }
    /************************************************************************************************/
    
    
    /****************************** EXTERNAL FUNCTIONS (ERC1400 INTERFACE) ****************************/
    function getDocument(bytes32 _dname) external view returns (string memory, bytes32){
        require(bytes(_documents[_dname].docURI).length != 0);
        
        return (_documents[_dname].docURI,_documents[_dname].docHash);
    }
    
    function setDocument(bytes32 _dname, string calldata _uri, bytes32 _documentHash) external{
        require(_isController[msg.sender]);
        
        _documents[_dname] = Doc({
            docURI:_uri,
            docHash:_documentHash
        });
        
        emit Document(_dname,_uri,_documentHash);
    }
    
    function balanceOfByPartition(bytes32 _partition, address _tokenHolder) external view returns (uint256){
        return _balanceOfByPartition[_tokenHolder][_partition];
    }
    
    function partitionsOf(address _tokenHolder) external view returns (bytes32[] memory){
        return _partitionsOf[_tokenHolder];
    }
    
    function transferWithData(address _to, uint256 _value, bytes calldata _data) external{
        byte arg1;
        bytes32 arg2;
        bytes32 arg3;
        (arg1,arg2,arg3) = _canTransfer(msg.sender,_to,"",_value);

        require(arg1 == hex"00");
        
        _transferByDefaultPartitions(msg.sender, msg.sender, _to, _value, _data);
    }
    
    function transferFromWithData(address _from, address _to, uint256 _value, bytes calldata _data) external{
        require(_isOperator(msg.sender,_from),"58");
        
        byte arg1;
        bytes32 arg2;
        bytes32 arg3;
        (arg1,arg2,arg3) = _canTransfer(_from,_to,"",_value);

        require(arg1 == hex"00");
        
        _transferByDefaultPartitions(msg.sender,_from,_to,_value,_data);
    }
    
    function transferByPartition(bytes32 _partition, address _to, uint256 _value, bytes calldata _data) external returns (bytes32){
        byte arg1;
        bytes32 arg2;
        bytes32 arg3;
        (arg1,arg2,arg3) = _canTransfer(msg.sender,_to,"",_value);

        require(arg1 == hex"00");
        
        return _transferByPartition(_partition, msg.sender, msg.sender, _to, _value, _data, "");
    }
    
    function operatorTransferByPartition(bytes32 _partition, address _from, address _to, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external returns (bytes32){
        require( _isOperatorForPartition(_partition,msg.sender,_from) || (_value <= _allowedByPartition[_partition][_from][msg.sender]),"58");
        
        byte arg1;
        bytes32 arg2;
        bytes32 arg3;
        (arg1,arg2,arg3) = _canTransfer(_from,_to,"",_value);

        require(arg1 == hex"00");
        
        if (_allowedByPartition[_partition][_from][msg.sender] >= _value){
            _allowedByPartition[_partition][_from][msg.sender] = _allowedByPartition[_partition][_from][msg.sender].sub(_value);
        }else{
            _allowedByPartition[_partition][_from][msg.sender] = 0;
        }
        
        return _transferByPartition(_partition,msg.sender,_from,_to,_value,_data,_operatorData);
    }
    
    function isControllable() external view returns (bool){
        return _isControllable;
    }

    function allowanceByPartition(bytes32 _partition, address _tokenHolder, address _spender) external view returns (uint256) {
        return _allowedByPartition[_partition][_tokenHolder][_spender];
    }

    function approveByPartition(bytes32 _partition, address _spender, uint256 _value) external returns (bool) {
        require(_spender != address(0), "56"); 
        _allowedByPartition[_partition][msg.sender][_spender] = _value;
        emit ApprovalByPartition(_partition, msg.sender, _spender, _value);
        return true;
    }
    
    function authorizeOperator(address _operator) external{
        require(_operator != msg.sender);
        
        _authorizedOperator[_operator][msg.sender] = true;
        emit AuthorizedOperator(_operator,msg.sender);
    }
    
    function revokeOperator(address _operator) external{
        require(_operator != msg.sender);
        
        _authorizedOperator[_operator][msg.sender] = false;
        emit RevokedOperator(_operator,msg.sender);
    }
    
    function authorizeOperatorByPartition(bytes32 _partition, address _operator) external{
        require(_operator != msg.sender);
        
        _authorizedOperatorByPartition[msg.sender][_partition][_operator] = true;
        emit AuthorizedOperatorByPartition(_partition,_operator,msg.sender);
    }
    
    function revokeOperatorByPartition(bytes32 _partition, address _operator) external{
        require(_operator != msg.sender);
        
        _authorizedOperatorByPartition[msg.sender][_partition][_operator] = false;
        emit RevokedOperatorByPartition(_partition,_operator,msg.sender);
    }
    
    function isOperator(address _operator, address _tokenHolder) external view returns (bool){
        return _isOperator(_operator,_tokenHolder);
    }
    
    function isOperatorForPartition(bytes32 _partition, address _operator, address _tokenHolder) external view returns (bool){
        return _isOperatorForPartition(_partition,_operator,_tokenHolder);
    }
    
    function isIssuable() external view returns (bool){
        return _isIssuable;
    }
    
    function issue(address _tokenHolder, uint256 _value, bytes calldata _data) external onlyMinter{
        require (_defaultPartitions.length != 0,"55");
        
        _issueByPartition(_defaultPartitions[0],msg.sender,_tokenHolder,_value,_data);
    }
    
    function issueByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes calldata _data) external onlyMinter{
        _issueByPartition(_partition,msg.sender,_tokenHolder,_value,_data);
    }
    
    function redeem(uint256 _value, bytes calldata _data) external{
        _redeemByDefaultPartitions(msg.sender,msg.sender,_value,_data);
    }
    
    function redeemFrom(address _tokenHolder, uint256 _value, bytes calldata _data) external{
        require(_isOperator(msg.sender,_tokenHolder),"58");
        
        _redeemByDefaultPartitions(msg.sender,_tokenHolder,_value,_data);
    }
    
    function redeemByPartition(bytes32 _partition, uint256 _value, bytes calldata _data) external{
        _redeemByPartition(_partition,msg.sender,msg.sender,_value,_data,"");   
    }
    
    function operatorRedeemByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes calldata _operatorData) external{
        require(_isOperatorForPartition(_partition,msg.sender,_tokenHolder),"58");
        
        _redeemByPartition(_partition,msg.sender,_tokenHolder,_value,"",_operatorData);
    }
    
    function canTransfer(address _to, uint256 _value, bytes calldata _data) external view returns (byte, bytes32){
        byte arg1;
        bytes32 arg2;
        bytes32 arg3;
        (arg1,arg2,arg3) = _canTransfer(msg.sender,_to,"",_value);
        
        return (arg1,arg2);
    }
    
    function canTransferFrom(address _from, address _to, uint256 _value, bytes calldata _data) external view returns (byte, bytes32){
        if(!_isOperator(msg.sender,_from))
            return(hex"58","");
        
        byte arg1;
        bytes32 arg2;
        bytes32 arg3;
        (arg1,arg2,arg3) = _canTransfer(_from,_to,"",_value);
        
        return (arg1,arg2);
    }
    
    function canTransferByPartition(address _from, address _to, bytes32 _partition, uint256 _value, bytes calldata _data) external view returns (byte, bytes32, bytes32){
        if (!_isOperatorForPartition(_partition,msg.sender,_from))
            return(hex"58","",_partition);
        
        return _canTransfer(_from,_to,_partition,_value);
    }
    
    function controllers() external view returns (address[] memory) {
        return _controllers;
    }
    
    function controllersByPartition(bytes32 partition) external view returns (address[] memory) {
        return _controllersByPartition[partition];
    }
    
    function setControllers(address[] calldata operators) external onlyOwner {
        _setControllers(operators);
    }
    
    function setPartitionControllers(bytes32 partition, address[] calldata operators) external onlyOwner {
         _setPartitionControllers(partition, operators);
    }
    
    function renounceControl() external onlyOwner {
        _isControllable = false;
    }

    function renounceIssuance() external onlyOwner {
        _isIssuable = false;
    }
    
    function setAllowlistStatus(bool _isEnable) external onlyOwner{
        _allowlistActivated = _isEnable;
    }
    
    function setBlockListStatus(bool _isEnable) external onlyOwner{
        _blocklistActivated = _isEnable;
    }

    function inAllowlist(address _userAddr) external view returns(bool){
        return _allowlist[_userAddr];
    }

    function inBlocklist(address _userAddr) external view returns(bool){
        return _blocklist[_userAddr];
    }
    
    function addAllowlist(address[] calldata operators) external onlyOwner{
        for(uint i = 0;i < operators.length; i++){
            _allowlist[operators[i]] = true;
        }
    }
    
    function revokeAllowlist(address[] calldata operators) external onlyOwner{
        for(uint i = 0;i < operators.length; i++){
            _allowlist[operators[i]] = false;
        }
    }
    
    function addBlocklist(address[] calldata operators) external onlyOwner{
        for(uint i = 0;i < operators.length; i++){
             _blocklist[operators[i]] = true;
        }
    }
    
    function revokeBlocklist(address[] calldata operators) external onlyOwner{
        for(uint i = 0;i < operators.length; i++){
            _blocklist[operators[i]] = false;
        }
    }
    /************************************************************************************************/  
    
    /************************************* Internal Method ******************************************/
    function _canTransfer(address _from, address _to, bytes32 _partition, uint256 _value) internal view returns (byte, bytes32, bytes32){
        if(_balances[_from] < _value)
            return(hex"52","",_partition);

        if(_to == address(0))
            return(hex"57","",_partition);

        if(_allowlistActivated){
            if(!_allowlist[_from] ||!_allowlist[_to])
                return(hex"32", "", _partition);
        }

        if(_blocklistActivated){
            if(_blocklist[_from] || _blocklist[_to])
                return(hex"33", "", _partition);
        }

        return(hex"00", "", _partition);
    }
    
    function _isOperator(address _operator,address _tokenHolder) internal view returns(bool){
        return (_operator == _tokenHolder 
        || _authorizedOperator[_operator][_tokenHolder] 
        || (_isControllable && _isController[_operator]));
    }
    
    function _isOperatorForPartition(bytes32 _partition,address _operator,address _tokenHolder) internal view returns(bool){
        return (_isOperator(_operator,_tokenHolder) 
        || _authorizedOperatorByPartition[_tokenHolder][_partition][_operator]
        || (_isControllable && _isControllerByPartition[_partition][_operator]));
    }
    
    function _issue(address _operator,address _to,uint256 _value,bytes memory _data) internal {
        require(_to != address(0), "57");
        
        _totalSupply = _totalSupply.add(_value);
        _balances[_to] = _balances[_to].add(_value);
        
        emit Issued(_operator,_to,_value,_data);
        emit Transfer(address(0),_to,_value);
    }

    function _issueByPartition(bytes32 _partition,address _operator,address _to,uint256 _value,bytes memory _data) internal {
        require(_to != address(0), "57"); 
        
        _issue(_operator,_to,_value,_data);
        _addTokenToPartition(_to,_partition,_value);
        
        emit IssuedByPartition(_partition,_operator,_to,_value,_data,"");
    }
    
    function _addTokenToPartition(address _to,bytes32 _partition,uint256 _value) internal {
        if(_value != 0){
            if(_indexOfPartitionsOf[_to][_partition] == 0){
                _partitionsOf[_to].push(_partition);
                _indexOfPartitionsOf[_to][_partition] = _partitionsOf[_to].length;
            }
            _balanceOfByPartition[_to][_partition] = _balanceOfByPartition[_to][_partition].add(_value);
            
            if (_indexOfTotalPartitions[_partition] == 0){
                _totalPartitions.push(_partition);
                _indexOfTotalPartitions[_partition] = _totalPartitions.length;
            }
            _totalSupplyByPartition[_partition] = _totalSupplyByPartition[_partition].add(_value);
        }
    }
    
    function _redeemByDefaultPartitions(address _operator,address _from,uint256 _value,bytes memory _data) internal {
        require(_defaultPartitions.length != 0,"55");
        
        uint256 _remainingValue = _value;
        uint256 _localBalance;
        
        for (uint i =0; i< _defaultPartitions.length;i++){
            _localBalance = _balanceOfByPartition[_from][_defaultPartitions[i]];
            
            if(_localBalance >= _remainingValue){
                _redeemByPartition(_defaultPartitions[i],_operator,_from,_value,_data,"");
                _remainingValue = 0;
                break;
            }else{
                _redeemByPartition(_defaultPartitions[i],_operator,_from,_localBalance,_data,"");
                _remainingValue = _remainingValue.sub(_localBalance);
            }
        }
        
        require(_remainingValue == 0,"52");
    }
    
    function _redeemByPartition(bytes32 _partition,address _operator,address _from,uint256 _value,bytes memory _data,bytes memory _operatorData) internal{
        require(_balanceOfByPartition[_from][_partition] >= _value, "52");
        
        _removeTokenFromPartition(_partition,_from,_value);
        _redeem(msg.sender,_from,_value,_data);
        
        emit RedeemedByPartition(_partition,_operator,_from,_value,_operatorData);
    }
    
    function _removeTokenFromPartition(bytes32 _partition,address _from,uint256 _value) internal{
        _balanceOfByPartition[_from][_partition] = _balanceOfByPartition[_from][_partition].sub(_value);
        _totalSupplyByPartition[_partition] = _totalSupplyByPartition[_partition].sub(_value);
        
        if(_totalSupplyByPartition[_partition] == 0){
            uint256 index = _indexOfTotalPartitions[_partition];
            require(index > 0, "50");
            
            bytes32 lastValue = _totalPartitions[_totalPartitions.length - 1];
            _totalPartitions[index - 1] = lastValue;
            _indexOfTotalPartitions[lastValue] = index;
            
            _totalPartitions.length -= 1;
            _indexOfTotalPartitions[_partition] = 0;
        }
        
        if(_balanceOfByPartition[_from][_partition] == 0){
            uint256 index = _indexOfPartitionsOf[_from][_partition];
            require(index > 0,"50");
            
            bytes32 lastValue = _partitionsOf[_from][_partitionsOf[_from].length - 1];
            _partitionsOf[_from][index - 1] = lastValue;
            _indexOfPartitionsOf[_from][lastValue] = index;
            
            _partitionsOf[_from].length -= 1;
            _indexOfPartitionsOf[_from][_partition] = 0;
        }
    }
    
    function _redeem(address _operator,address _from,uint256 _value,bytes memory _data) internal{
        require(_from != address(0), "56");
        require(_balances[_from] >= _value,"52");
        
        _balances[_from] = _balances[_from].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        
        emit Redeemed(_operator,_from,_value,_data);
        emit Transfer(_from,address(0),_value);
    }
    
    function _transferByDefaultPartitions(address _operator,address _from,address _to,uint256 _value,bytes memory _data) internal{
        require(_defaultPartitions.length != 0,"55");
        
        uint256 _remainingValue = _value;
        uint256 _localBalance;
        
        for(uint i=0;i<_defaultPartitions.length;i++){
            _localBalance = _balanceOfByPartition[_from][_defaultPartitions[i]];
            if(_localBalance >= _remainingValue){
                _transferByPartition(_defaultPartitions[i],_operator,_from,_to,_remainingValue,_data,"");
                _remainingValue = 0;
                break;
            }else if(_localBalance != 0){
                 _transferByPartition(_defaultPartitions[i],_operator,_from,_to,_localBalance,_data,"");
                 _remainingValue = _remainingValue.sub(_localBalance);
            }
        }
        
        require(_remainingValue == 0,"52");
    }
    
    function _transferByPartition(bytes32 _partition,address _operator,address _from,address _to,uint256 _value,bytes memory _data,bytes memory _operatorData) internal returns(bytes32){
        require(_balanceOfByPartition[_from][_partition] >= _value,"52");
        
        bytes32 toPartition = _partition;
        
        if(_operatorData.length != 0 && _data.length >= 64){
            toPartition = _getDestinationPartition(_partition,_data);
        }
        
        _removeTokenFromPartition(_partition,_from,_value);
        _transferWithData(_from,_to,_value);
        _addTokenToPartition(_to,_partition,_value);
        
        emit TransferByPartition(_partition,_operator,_from,_to,_value,_data,_operatorData);
        
        if(toPartition != _partition){
            emit ChangedPartition(_partition,toPartition,_value);
        }
        
        return toPartition;
    }
    
    function _getDestinationPartition(bytes32 fromPartition, bytes memory data) internal pure returns(bytes32 toPartition) {
        bytes32 changePartitionFlag = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
        bytes32 flag;
        assembly {
            flag := mload(add(data, 32))
        }
        if(flag == changePartitionFlag) {
            assembly {
            toPartition := mload(add(data, 64))
            }
        } else {
            toPartition = fromPartition;
        }
    }
    
    function _transferWithData(address _from,address _to,uint256 _value) internal{
        require(_to != address(0),"57");
        require(_balances[_from] >= _value,"52");
        
        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        
        emit Transfer(_from,_to,_value);
    }
    
    function _setControllers(address[] memory operators) internal {
        for (uint i = 0; i<_controllers.length; i++){
            _isController[_controllers[i]] = false;
        }
        for (uint j = 0; j<operators.length; j++){
            _isController[operators[j]] = true;
        }
        _controllers = operators;
    }
    
    function _setPartitionControllers(bytes32 partition, address[] memory operators) internal {
        for (uint i = 0; i<_controllersByPartition[partition].length; i++){
            _isControllerByPartition[partition][_controllersByPartition[partition][i]] = false;
        }
        for (uint j = 0; j<operators.length; j++){
            _isControllerByPartition[partition][operators[j]] = true;
        }
        _controllersByPartition[partition] = operators;
    }
    /************************************************************************************************/
    
    
//status code
//0x58 invalid operator
//0x57 invalid receiver
//0x56 invalid sender
//0x55 default partitions is null
//0x53 insufficient allowance
//0x52 insufficient balance
//0x50 invalid partitions
//0x31 In the blocked list
//0x32 Not in the allowed list
}