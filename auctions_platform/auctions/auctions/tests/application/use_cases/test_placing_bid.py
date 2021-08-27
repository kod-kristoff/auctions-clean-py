from unittest.mock import Mock

import pytest

from foundation.value_objects import Money
from foundation.value_objects.factories import get_dollars

from auctions.application.use_cases import PlacingBid
from auctions.application.use_cases.placing_bid import (
    PlacingBidInputDto,
    PlacingBidOutputDto,
)
from auctions.domain.entities import Auction


@pytest.fixture()
def bidder_id() -> int:
    return 1


@pytest.fixture()
def amount() -> Money:
    return get_dollars("12.00")


@pytest.fixture()
def input_dto(
    auction: Auction, bidder_id: int, amount: Money
) -> PlacingBidInputDto:
    return PlacingBidInputDto(bidder_id, auction.id, amount)


def test_presents_output_dto(
    placing_bid_uc: PlacingBid,
    input_dto: PlacingBidInputDto,
    placing_bid_output_boundary_mock: Mock,
    auction: Auction
) -> None:
    placing_bid_uc.execute(input_dto)

    expected_output_dto = PlacingBidOutputDto(is_winner=True, current_price=input_dto.amount)
    placing_bid_output_boundary_mock.present.assert_called_with(expected_output_dto)
