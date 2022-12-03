pragma solidity ^0.4.10;

// Using Ethpm library 'zeppelin' and using the Ownable contract which takes care of contracts ownership
import 'zeppelin/contracts/ownership/Ownable.sol';

// This contract is an implementation of a personal wallet(whose ownership can be transferred)
// using the zeppelin package and Ownable contract
contract LibraryDemo is Ownable{

  string name;
  uint regno;

/** @dev Set the value of the variables
  * @param _name Name you want to set
  * @param _number The number you set
  */
  function setvalues(string _name,uint _number) onlyOwner {
    name=_name;
    regno=_number;
  }

  /** @dev Get the value of the variables
    * @return Name name you had set
    * @return Number the number you had set
    */
  function getvalues() constant returns(string Name,uint Number) {
    Name=name;
    Number=regno;
  }

  /** @dev Add money to your wallet
    */
  function addmoney() payable{
    this.transfer(msg.value);
  }

  /** @dev Withdraw money from wallet
    * @param value Money you want to withdraw
    */
  function withdrawmoney(uint value) onlyOwner {
    msg.sender.transfer(value);
  }

  /** @dev Show wallet balance
    * @return show the wallet balance
    */
  function showWalletBalance() constant returns(uint){
    return this.balance;
  }

//payable fallback function
  function() payable{

  }
}
