// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;
  mapping (address => uint256) public balances;
  uint256 public constant threshold = 1 ether;
  bool openToWithdraw = false;
  bool executed = false;

  event Stake(address indexed user, uint256 amount);

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  modifier notcompleted {
    bool completed = exampleExternalContract.completed();
    require(!completed, "Contract is already completed");
    _;
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )

  function stake() public payable {
    balances[msg.sender] += msg.value;
    console.log("Stake: ",msg.sender, msg.value);
    emit Stake(msg.sender, msg.value);
  }

  uint256 public deadline = block.timestamp + 72 hours;

  
  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance

  function execute() public notcompleted{
    require( block.timestamp >= deadline, "Haven't reached the deadline yet" );
      if(address(this).balance >= threshold) {
        exampleExternalContract.complete{value: address(this).balance}();
      }
      else {
        openToWithdraw = true;
      }
    executed = true;
  }

  

  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  function timeLeft() public view returns(uint256) {
    if(block.timestamp >= deadline) {
      return 0;
    }
    return deadline - block.timestamp;
  }

  function withdraw() public notcompleted{
    require(openToWithdraw,"Contract is not open for withdraw yet!");
    uint256 temp = balances[msg.sender]; 
    balances[msg.sender] = 0;
    (, bytes memory data) = (msg.sender).call{value: temp}("");
  }



  // Add the `receive()` special function that receives eth and calls stake()

  function receive() public payable {
    stake();
  }
}
