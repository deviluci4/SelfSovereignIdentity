// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SSI {
    uint256 public docCount = 0;

    struct Document {
        uint256 id;
        string user_did;
        string did;
        string name;
        string fathersName;
        string email;
        string phone;
        string permanentAddress;
        string signature;
        bool status;
    }

    mapping(uint256 => Document) public documents;

    function addDocument(
        string memory user_did,
        string memory did,
        string memory name,
        string memory fathersName,
        string memory email,
        string memory phone,
        string memory permanentAddress
    ) public {
        documents[docCount] = Document(
            docCount,
            user_did,
            did,
            name,
            fathersName,
            email,
            phone,
            permanentAddress,
            "",
            false
        );
        docCount++;
    }

    function getDocCount() public view returns (uint256) {
        return docCount;
    }

    function getDocument(uint256 id)
        public
        view
        returns (
            string memory user_did,
            string memory did,
            string memory name,
            string memory fathersName,
            string memory email,
            string memory phone,
            string memory permanentAddress,
            bool status
        )
    {
        Document memory doc = documents[id];
        return (
            doc.user_did,
            doc.did,
            doc.name,
            doc.fathersName,
            doc.email,
            doc.phone,
            doc.permanentAddress,
            doc.status
        );
    }

    function verifyDocument(
        uint256 id,
        string memory user_did,
        string memory did,
        string memory name,
        string memory fathersName,
        string memory email,
        string memory phone,
        string memory permanentAddress,
        bytes memory signature
    ) public {
        require(id < docCount, "Invalid document ID");
        Document storage doc = documents[id];

        bytes32 messageHash = keccak256(
            abi.encodePacked(
                user_did,
                did,
                name,
                fathersName,
                email,
                phone,
                permanentAddress
            )
        );

        address recoveredAddress = recoverSigner(messageHash, signature);

        require(
            recoveredAddress == bytesToAddress(bytes(user_did)),
            "Signature verification failed"
        );

        doc.user_did = user_did;
        doc.did = did;
        doc.name = name;
        doc.fathersName = fathersName;
        doc.email = email;
        doc.phone = phone;
        doc.permanentAddress = permanentAddress;
        doc.signature = string(signature);
        doc.status = true;
    }

    function totalDocuments() public view returns (uint256) {
        return docCount;
    }

    function showAllDocs(string memory user_did)
        public
        view
        returns (uint256[] memory)
    {
        uint256[] memory indices = new uint256[](docCount);
        uint256 count = 0;
        for (uint256 i = 0; i < docCount; i++) {
            if (
                keccak256(abi.encodePacked((documents[i].user_did))) ==
                keccak256(abi.encodePacked((user_did)))
            ) {
                indices[count] = i;
                count++;
            }
        }
        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = indices[i];
        }
        return result;
    }

    function recoverSigner(bytes32 messageHash, bytes memory signature)
        internal
        pure
        returns (address)
    {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28, "Invalid signature recovery id");

        return ecrecover(messageHash, v, r, s);
    }

    function bytesToAddress(bytes memory data)
        internal
        pure
        returns (address addr)
    {
        assembly {
            addr := mload(add(data, 20))
        }
    }
}