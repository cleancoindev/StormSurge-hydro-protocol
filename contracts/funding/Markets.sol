/*

    Copyright 2019 The Hydro Protocol Foundation

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

*/
pragma solidity 0.5.8;
pragma experimental ABIEncoderV2;

import "../lib/Store.sol";
import "../lib/Types.sol";
import "../lib/Events.sol";
import "../interfaces/IOracle.sol";

library Markets {
    modifier marketNotExist(
        Store.State storage state,
        Types.Market memory market
    ) {
        require(!isMarketExist(state, market), "MARKET_IS_ALREADY_EXIST");
        _;
    }

    modifier marketAssetsValid(
        Store.State storage state,
        Types.Market memory market
    ) {
        require(state.oracles[market.baseAsset] != IOracle(address(0)), "MARKET_BASE_ASSET_INVALID");
        require(state.oracles[market.quoteAsset] != IOracle(address(0)), "MARKET_QUOTE_ASSET_INVALID");
        _;
    }

    function isMarketExist(
        Store.State storage state,
        Types.Market memory market
    )
        internal
        view
        returns (bool)
    {
        for(uint32 i = 0; i < state.marketsCount; i++) {
            if (state.markets[i].baseAsset == market.baseAsset && state.markets[i].quoteAsset == market.quoteAsset) {
                return true;
            }
        }

        return false;
    }

    function getMarket(
        Store.State storage state,
        uint16 marketID
    )
        internal
        view
        returns (Types.Market memory)
    {
        return state.markets[marketID];
    }

    function getAllMarketsCount(
        Store.State storage state
    )
        internal
        view
        returns (uint256)
    {
        return state.marketsCount;
    }

    function addMarket(
        Store.State storage state,
        Types.Market memory market
    )
        internal
        marketNotExist(state, market)
        marketAssetsValid(state, market)
    {
        state.markets[state.marketsCount++] = market;
        Events.logMarketCreate(market);
    }
}