enum ActionType {
  SHOW_OPTIONS,
  REJECT_ALL,
  ACCEPT_ALL,
  MSG_CANCEL,
  SAVE_AND_EXIT,
  PM_DISMISS
}

ActionType? actionTypeFromCode(int? code) {
  if (code == null) return null;

  switch (code) {
    case 12: return ActionType.SHOW_OPTIONS;
    case 13: return ActionType.REJECT_ALL;
    case 11: return ActionType.ACCEPT_ALL;
    case 15: return ActionType.MSG_CANCEL;
    case 1: return ActionType.SAVE_AND_EXIT;
    case 2: return ActionType.PM_DISMISS;
  }

  throw UnsupportedError('Unknown actionCode $code');
}