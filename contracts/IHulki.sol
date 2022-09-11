pragma solidity ^0.8.11;

interface IHulki {
    function mint(
        uint8 _mode,
        uint8 _amount,
        uint8 _evo,
        uint256 _tokenId,
        address _to
    ) external;

    function getTokenEvo(uint256 _tokenId) external view returns (uint256);

    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}
