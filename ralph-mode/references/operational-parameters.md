# Operational Parameters

- Max iteration time: 10 minutes
- Total session timeout: 60 minutes
- If iteration exceeds limit: Log blocker, exit
```

**Why:** Prevents infinite loops on stuck tasks, allows parent agent to intervene.
