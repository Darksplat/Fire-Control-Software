from stfz_handler import STFZHandler


def test_add_and_query_zone():
    handler = STFZHandler(config_file="/tmp/nonexistent.json")
    handler.add_zone((10, 10, 50, 50))

    assert handler.is_target_in_zone((20, 20, 5, 5)) is True
    assert handler.is_target_in_zone((100, 100, 5, 5)) is False


def test_normalizes_negative_dimensions():
    handler = STFZHandler(config_file="/tmp/nonexistent.json")
    handler.add_zone((100, 100, -20, -10))

    assert handler.zones[0] == (80, 90, 20, 10)


def test_save_and_load_zones(tmp_path):
    config_path = tmp_path / "zones.json"
    handler = STFZHandler(config_file=str(config_path))
    handler.add_zone((5, 5, 15, 20))
    handler.save_zones()

    new_handler = STFZHandler(config_file=str(config_path))
    new_handler.load_zones()

    assert new_handler.zones == [(5, 5, 15, 20)]
