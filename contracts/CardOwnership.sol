// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "./CardGame.sol";
import "./utils/ERC721.sol";
import "./utils/SafeMath.sol";

/**
* @title CardOwnership
* @dev Contract containing all the card ownership logic
*/
contract CardOwnership is CardGame, ERC721 {

    using SafeMath for uint256;

    event Trade(address from, address to, uint256 tokenIdFrom, uint256 tokenIdTo);

    mapping (uint => address) cardApprovals;

    /**
    * @param _owner - Player to check number of cards
    * @return Number of cards owned by that player
    * @dev Checks the balance of cards of a player
    */
    function balanceOf(address _owner) external view override returns (uint256) {
        return ownerCardCount[_owner];
    }

    /**
    * @param _tokenId - id of the Token to be analized
    * @return Address of the user that owns the specified token
    * @dev Checks the owner of the specified token
    */
    function ownerOf(uint256 _tokenId) external view override returns (address) {
        return cardToOwner[_tokenId];
    }

    /**
    * @param _from - Address of the player transfering the token
    * @param _to - Address of the player receiving the token
    * @param _tokenId - Token that will be transfered
    * @dev Transfers a token from one user to other
    */
    function _transfer(address _from, address _to, uint256 _tokenId) internal override {
        // Once approved we map this token to the address 0 to remove the approval of transfer of this token
        _approve(address(0), _tokenId);
        ownerCardCount[_to] = ownerCardCount[_to].add(1);
        ownerCardCount[msg.sender] = ownerCardCount[msg.sender].sub(1);
        cardToOwner[_tokenId] = _to;
        emit Transfer(_from, _to, _tokenId);
    }

    /**
    * @param _from - Address of the player transfering the token
    * @param _to - Address of the player receiving the token
    * @param _tokenId - Token that will be transfered
    * @dev Transfers a token from one user to other
    */
    function transferFrom(address _from, address _to, uint256 _tokenId) external override payable {
        require (cardToOwner[_tokenId] == msg.sender || cardApprovals[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
    }

    /**
    * @param _from - Address of the player trading their token
    * @param _to - Address of the other player trading their token
    * @param _tokenIdFrom - Token that will be traded
    * @param _tokenIdTo - Other token that will be traded
    * @dev Transfers a token from one user to other
    */
    function trade(address _from, address _to, uint256 _tokenIdFrom, uint256 _tokenIdTo) external payable {
        require (cardApprovals[_tokenIdFrom] == _to || cardApprovals[_tokenIdTo] == _from);
        _transfer(_from, _to, _tokenIdFrom);
        _transfer(_to, _from, _tokenIdTo);
        emit Trade(_from, _to, _tokenIdFrom, _tokenIdTo);
    }

    /**
    * @param _approved - Address of the player to be approved to receive a token
    * @param _tokenId - Token that will be approved for transfering
    * @dev Internal implementation of approving a user and a token. 
    */
    function _approve(address _approved, uint256 _tokenId) internal virtual override   {
        cardApprovals[_tokenId] = _approved;
        emit Approval(msg.sender, _approved, _tokenId);
    }

    /**
    * @param _to - Address of the player to be approved to receive a token
    * @param _tokenId - Token that will be approved for transfering
    * @dev Allows the owner of a token to approve a user and a token. 
    */
    function approve(address _to, uint256 _tokenId) public virtual override payable onlyOwnerOf(_tokenId){
        _approve(_to, _tokenId);
    }
}