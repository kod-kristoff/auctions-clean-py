def test_presents_output_dto(
    placing_bid_uc: PlacingBid, input_dto: PlacingBidInputDto, placing_bid_output_boundary_mock: Mock, auction: Auction
) -> None:
    placing_bid_uc.execute(input_dto)

    expected_output_dto = PlacingBidOutputDto(is_winner=True, current_price=input_dto.amount)
    placing_bid_output_boundary_mock.present.assert_called_with(expected_output_dto)
