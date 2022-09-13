// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import { ByteHasher } from './helpers/ByteHasher.sol';
import { IWorldID } from './interfaces/IWorldID.sol';
import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Contract is ERC721URIStorage {
    using ByteHasher for bytes;

    error InvalidNullifier();
    IWorldID internal immutable worldId;
    uint256 internal immutable groupId = 1;
    mapping(uint256 => bool) internal nullifierHashes;

    event ProofVerified(address user);

    constructor(IWorldID _worldId) ERC721("MyProfile", "PNFT"){
        worldId = _worldId;
    }

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    function mintProfileNft(address user, string memory tokenURI) public returns(uint256) {
        uint256 newItemId = _tokenIds.current();
        _mint(user, newItemId);
        _setTokenURI(newItemId, tokenURI);

        _tokenIds.increment();
        return newItemId;
    }

    function verifyAndExecute(
        string memory tokenURI,
        address receiver,
        uint256 root,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) public {
        // first, we make sure this person hasn't done this before
        if (nullifierHashes[nullifierHash]) revert InvalidNullifier();

        // then, we verify they're registered with WorldID, and the input they've provided is correct
        worldId.verifyProof(
            root,
            groupId,
            abi.encodePacked(receiver).hashToField(),
            nullifierHash,
            abi.encodePacked(address(this)).hashToField(),
            proof
        );

        // finally, we record they've done this, so they can't do it again (proof of uniqueness)
        nullifierHashes[nullifierHash] = true;

        // logic
        emit ProofVerified(receiver);
        mintProfileNft(receiver, tokenURI);
    }
}
