// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Credentials {
    struct Credential {
        string username;
        string password;
    }

    mapping(address => Credential) private credentials;

    function storeCredential(string memory _username, string memory _password) public {
        credentials[msg.sender] = Credential(_username, _password);
    }

    function getCredential(address _user) public view returns (string memory, string memory) {
        Credential memory userCredential = credentials[_user];
        return (userCredential.username, userCredential.password);
    }
}