// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Allowance is Ownable {
    using SafeMath for uint;
    event AllowanceChanged(address indexed _forWho, address indexed _fromWho, uint _oldAmount, uint _newAmount);
        
    mapping (address => uint) public allowance;

    function addAllowance(address _who, uint _amount) public onlyOwner {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], _amount);
        allowance[_who] = allowance[_who].add(_amount);
    }

    function reduceAllowance(address _who, uint _amount) internal {
        emit AllowanceChanged(_who, msg.sender, allowance[_who], allowance[_who] - _amount);
        allowance[_who] = allowance[_who].sub(_amount);
    }

    function isOwner() public view virtual returns (bool) {
        return msg.sender == owner();
    }

    modifier ownerOrAllowed(uint _amount) {
        require((isOwner() || allowance[msg.sender] >= _amount), "You are not allowed");
        _;
    }
}


contract SimpleWallet is Allowance{

    /** 
    Return the balance of the contract
    */
    function getBalance() public view returns (uint){
        return address (this).balance;
    }

    function withdrawMoney(address payable _to, uint _amount) public ownerOrAllowed(_amount) {
        require(_amount <= address(this).balance, "There are not enough funds in the smart contract");
        if (!isOwner()){
            reduceAllowance(msg.sender, _amount);
        }
        _to.transfer(_amount);
    }

    /**
    Drain the contract of all funds back to the owner of the contract on close
    */
    function drainContract(address payable _to) public onlyOwner {
        _to.transfer(getBalance());
    }

    function fallback() external payable {

    }

    /** 
    Override the renounceownership function to prevent accidental loss of ownership of the contract
    */
    function renounceOwnership() public virtual override onlyOwner {
        revert("Can't renounce ownership");
    }
}
