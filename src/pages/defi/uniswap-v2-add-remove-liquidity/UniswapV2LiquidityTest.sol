// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import "../src/UniswapV2Liquidity.sol";

IERC20 constant WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
IERC20 constant USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
IERC20 constant PAIR = IERC20(0x0d4a11d5EEaaC28EC3F61d100daF4d40471f1852);

contract UniswapV2AddLiquidityTest is Test {
    UniswapV2AddLiquidity private uni = new UniswapV2AddLiquidity();

    //  Add WETH/USDT Liquidity to Uniswap
    function testAddLiquidity() public {
        // Deal test USDT and WETH to this contract
        deal(address(USDT), address(this), 1e6 * 1e6);
        assertEq(USDT.balanceOf(address(this)), 1e6 * 1e6, "USDT balance incorrect");
        deal(address(WETH), address(this), 1e6 * 1e18);
        assertEq(WETH.balanceOf(address(this)), 1e6 * 1e18, "WETH balance incorrect");

        // Approve uni for transferring
        safeApprove(WETH, address(uni), 1e64);
        safeApprove(USDT, address(uni), 1e64);

        uni.addLiquidity(address(WETH), address(USDT), 1 * 1e18, 3000.05 * 1e6);

        assertGt(PAIR.balanceOf(address(uni)), 0, "pair balance 0");
    }

    // Remove WETH/USDT Liquidity from Uniswap
    function testRemoveLiquidity() public {
        // Deal LP tokens to uni
        deal(address(PAIR), address(uni), 1e10);
        assertEq(PAIR.balanceOf(address(uni)), 1e10, "LP tokens balance = 0");
        assertEq(USDT.balanceOf(address(uni)), 0, "USDT balance non-zero");
        assertEq(WETH.balanceOf(address(uni)), 0, "WETH balance non-zero");

        uni.removeLiquidity(address(WETH), address(USDT));

        assertEq(PAIR.balanceOf(address(uni)), 0, "LP tokens balance != 0");
        assertGt(USDT.balanceOf(address(uni)), 0, "USDT balance = 0");
        assertGt(WETH.balanceOf(address(uni)), 0, "WETH balance = 0");
    }


    /**
     * @dev Required for tokens that do not follow the ERC20 standard.
     * For example, USDT `transferFrom` doesn't return a bool.
     * This function ensures that we are never blocked by a token's `transferFrom` implementation.
     * Without it, the `transferFrom` call would fail.
     */
    function safeTransferFrom(
        IERC20 token,
        address sender,
        address recipient,
        uint amount
    ) internal {
        (bool successTransferFrom, ) = address(token).call(
            abi.encodeCall(IERC20.transferFrom, (sender, recipient, amount))
        );
        require(successTransferFrom, "transferFrom failed");
    }

    /**
     * @dev Required for tokens that do not follow the ERC20 standard.
     * For example, USDT `approve` doesn't return a bool.
     * This function ensures that we are never blocked by a token's `approve` implementation.
     * Without it, the `approve` call would fail.
     */
    function safeApprove(IERC20 token, address spender, uint amount) internal {
        (bool successApprove, ) = address(token).call(
            abi.encodeCall(IERC20.approve, (spender, amount))
        );
        require(successApprove, "approve failed");
    }
}
