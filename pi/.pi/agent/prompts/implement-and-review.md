---
description: Worker implements, reviewer reviews, worker applies feedback
---
Execute this as a sequential workflow using `Agent` calls:

1. First, call `Agent({subagent_type: "worker", prompt: "Implement: $@", description: "Implement changes", run_in_background: false})` to implement.
2. Then, call `Agent({subagent_type: "reviewer", prompt: "Review the implementation from step 1. Context: [worker's output]. Focus on the files changed and any risk areas.", description: "Review changes", run_in_background: false})` to review.
3. Finally, call `Agent({subagent_type: "worker", prompt: "Apply the feedback from the review. Context - what was implemented: [worker output] - review feedback: [reviewer output]", description: "Apply review feedback", run_in_background: false})` to apply review feedback.

Feed each agent's full output into the next agent's prompt. All run in the foreground so results are available inline.
