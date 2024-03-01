// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VerifierSSI {
    uint256 public reqCount = 0;
    Request[] public requests;

    struct Request {
        uint256 id;
        string user_did;
        string V_publicKey;
        string comp_and_doc;
        string encAddress;
        string request_at;
        bool removed;
        bool review;
        bool status;
    }

    function makeRequest(
        string memory user_did,
        string memory V_publicKey,
        string memory comp_and_doc,
        string memory request_at
    ) public {
        reqCount++;
        requests.push(Request(reqCount, user_did, V_publicKey, comp_and_doc, "", request_at, false, false, false));
    }

    function acceptedByUser(uint256 id, string memory encAddress) public {
        require(id > 0 && id <= reqCount, "Invalid request ID");
        Request storage req = requests[id - 1];
        req.encAddress = encAddress;
        req.status = true;
    }

    function showRequest(string memory user_did) public view returns (uint256[] memory) {
        uint256[] memory indices = new uint256[](reqCount);
        uint256 counter = 0;
        for (uint256 i = 0; i < reqCount; i++) {
            if (keccak256(bytes(requests[i].user_did)) == keccak256(bytes(user_did))) {
                indices[counter++] = i + 1;
            }
        }
        uint256[] memory result = new uint256[](counter);
        for (uint256 i = 0; i < counter; i++) {
            result[i] = indices[i];
        }
        return result;
    }

    function showAllRequest() public view returns (uint256) {
        return reqCount;
    }

    function getIndividualRequest(uint256 id) public view returns (uint256, string memory, string memory, string memory, string memory, string memory, bool, bool, bool) {
        require(id > 0 && id <= reqCount, "Invalid request ID");
        Request memory req = requests[id - 1];
        return (req.id, req.user_did, req.V_publicKey, req.comp_and_doc, req.encAddress, req.request_at, req.removed, req.review, req.status);
    }

    function verifyDocument(uint256 id, bool review, bool status) public {
        require(id > 0 && id <= reqCount, "Invalid request ID");
        Request storage req = requests[id - 1];
        req.review = review;
        req.status = status;
    }

    function removeRequest(uint256 id) public {
        require(id > 0 && id <= reqCount, "Invalid request ID");
        Request storage req = requests[id - 1];
        req.removed = true;
    }
}