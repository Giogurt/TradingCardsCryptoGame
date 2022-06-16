// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./CardHelper.sol";

contract CardGame is CardHelper {

  function attack(uint _cardId, uint _enemyCardId) external onlyOwnerOf(_cardId) {
    Card storage myCard = cards[_cardId];
    Card storage enemyCard = cards[_enemyCardId];

    if(enemyCard.health - (myCard.attack - enemyCard.defense) <= myCard.health - (enemyCard.attack - myCard.defense)) {
      _upgradeCardStats(_cardId);
    } else {
      _upgradeCardStats(_enemyCardId);
    }
  }
}
