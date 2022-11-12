// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.6.10 <0.8.0;

import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "./RewardClaimer.sol";

interface IBribeVault {
    function BRIBE_VAULT() external view returns (address);

    /**
        @notice Deposit bribe for a proposal (ERC20 tokens only)
        @param  proposal  bytes32  Proposal
        @param  token     address  Token
        @param  amount    uint256  Token amount
     */
    function depositBribeERC20(
        bytes32 proposal,
        address token,
        uint256 amount
    ) external;
}

contract Briber is Ownable, CoreUtility {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 private constant MAX_ITERATIONS = 500;

    IBribeVault public immutable bribeVault;
    RewardClaimer public immutable rewardClaimer;
    address public immutable token;

    uint256 public claimableChess;

    uint256 private _chessIntegral;
    uint256 private _chessIntegralTimestamp;
    uint256 private _rate;

    constructor(
        address bribeVault_,
        address rewardClaimer_,
        address token_
    ) public {
        bribeVault = IBribeVault(bribeVault_);
        rewardClaimer = RewardClaimer(rewardClaimer_);
        token = token_;
    }

    function bribe(bytes32 proposal, uint256 bribeAmount) external onlyOwner {
        rewardClaimer.claimRewards(bribeAmount);
        IERC20(token).safeApprove(bribeVault.BRIBE_VAULT(), bribeAmount);
        bribeVault.depositBribeERC20(proposal, token, bribeAmount);
    }
}
