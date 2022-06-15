// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./TradingCards.sol";

contract CardHelper is TradingCards {

  uint boosterPackFee = 0.004 ether;
  uint8 boosterPackQuantity = 5;

//   modifier aboveLevel(uint _level, uint _zombieId) {
//     require(zombies[_zombieId].level >= _level);
//     _;
//   }

  function withdraw() external onlyOwner {
    address payable _owner = payable(owner());
    _owner.transfer(address(this).balance);
  }

  function setBoosterPackFee(uint _fee) external onlyOwner {
    boosterPackFee = _fee;
  }

  function setBoosterPackQuantity(uint8 _quantity) external onlyOwner {
    boosterPackQuantity = _quantity;
  }


  function setStatsDigits(uint _digits) external onlyOwner {
    statsDigits = _digits;
  }

  function setClassDigits(uint _digits) external onlyOwner {
    classDigits = _digits;
  }

  function setSkillDigits(uint _digits) external onlyOwner {
    skillDigits = _digits;
  }

  function _generateBoosterPack(address _player) internal {
      for(uint i = 0; i < boosterPackQuantity; i++) {
          _createRandomCard(_player);
      }
  }

  function acquireBoosterPack() payable external {
    require(msg.value == boosterPackFee);
    _generateBoosterPack(msg.sender);
  }

//   function levelUp(uint _zombieId) external payable {
//     require(msg.value == levelUpFee);
//     zombies[_zombieId].level = zombies[_zombieId].level.add(1);
//   }

//   function changeName(uint _zombieId, string calldata _newName) external aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
//     zombies[_zombieId].name = _newName;
//   }

//   function changeDna(uint _zombieId, uint _newDna) external aboveLevel(20, _zombieId) onlyOwnerOf(_zombieId) {
//     zombies[_zombieId].dna = _newDna;
//   }

//   function getZombiesByOwner(address _owner) external view returns(uint[] memory) {
//     uint[] memory result = new uint[](ownerZombieCount[_owner]);
//     uint counter = 0;
//     for (uint i = 0; i < zombies.length; i++) {
//       if (zombieToOwner[i] == _owner) {
//         result[counter] = i;
//         counter++;
//       }
//     }
//     return result;
//   }

}
