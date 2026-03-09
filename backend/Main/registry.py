from importlib import import_module


DEFAULT_HANDLER_BY_MODE = {
    "FTP": "Main.handlers.default.DefaultHandler",
    "FTPUPLOAD": "Main.handlers.default.DefaultHandler",
    "API": "Main.handlers.default.DefaultHandler",
    "SPAPI": "Main.handlers.default.DefaultHandler",
    "SPITOSP": "Main.handlers.default.DefaultHandler",
    "MSPITOSP": "Main.handlers.default.DefaultHandler",
    "TRANSFERTABLE": "Main.handlers.default.DefaultHandler",
    "FILETEMPLATEEXPORT": "Main.handlers.default.DefaultHandler",
    "PROCEDURE": "Main.handlers.default.DefaultHandler",
    "CUSTOMIZE": "Main.handlers.default.DefaultHandler",
    "PROC_CUSTOMETR": "Main.handlers.default.DefaultHandler",
}


def _load_class(dotted_path: str):
    module_name, class_name = dotted_path.rsplit(".", 1)
    module = import_module(module_name)
    return getattr(module, class_name)


def resolve_handler(schedule_mode: str, mapping_table: str):
    mode = (schedule_mode or "").upper()

    # 先嘗試客製化 Handler：Main.handlers.customize.<MAPPING_TABLE>.Handler
    try:
        custom_cls = _load_class(f"Main.handlers.customize.{mapping_table.upper()}.Handler")
        return custom_cls()
    except Exception:
        pass

    if mode not in DEFAULT_HANDLER_BY_MODE:
        raise ValueError(f"不支援的 schedule_mode: {mode}")

    default_cls = _load_class(DEFAULT_HANDLER_BY_MODE[mode])
    return default_cls()
