# GitHub Token Scope Analysis for OA-05

## AI Review & Guarded Merge Automation

### Current Permissions in ai-code-review.yml

The workflow currently uses:

```yaml
permissions:
  contents: read
  pull-requests: write
  checks: write
  statuses: write
```

### Permission Analysis

#### ✅ Sufficient Permissions for Current Features

1. **contents: read**

   - ✅ Checkout code
   - ✅ Read files for diff analysis
   - ✅ Access repository content
   - ❌ Cannot merge PRs (requires write)

2. **pull-requests: write**

   - ✅ Post review comments
   - ✅ Update PR labels
   - ✅ Request reviews
   - ✅ Approve/request changes (via review API)
   - ❌ Cannot merge (different permission)

3. **checks: write**

   - ✅ Create check runs
   - ✅ Update check run status
   - ✅ Add annotations to code

4. **statuses: write**
   - ✅ Create commit statuses
   - ✅ Update status checks
   - ✅ Block/unblock merges via status

### Auto-Merge Requirements

To enable automated PR merging, we need **ONE OF**:

#### Option 1: Using GITHUB_TOKEN (Recommended for security)

```yaml
permissions:
  contents: write # Required for merge operation
  pull-requests: write # Already have
```

**Limitations:**

- Cannot trigger subsequent workflows (by GitHub design)
- Some branch protection rules may block automation
- Safer as it's scoped to the workflow run

#### Option 2: Using Personal Access Token (PAT)

```yaml
env:
  GH_TOKEN: ${{ secrets.PAT_TOKEN }}
```

**Requirements:**

- Create PAT with `repo` scope (full repository access)
- Add as repository secret
- More powerful but higher security risk

### Security Considerations

#### Risk Analysis

| Approach           | Security Risk | Capability      | Recommendation      |
| ------------------ | ------------- | --------------- | ------------------- |
| Status checks only | ⬛️ None       | Block merges    | ✅ Current (safe)   |
| contents: write    | 🟨 Low        | Auto-merge      | ✅ Safe with guards |
| PAT token          | 🟥 High       | Full automation | ⚠️ Use sparingly    |

#### Best Practices

1. **Use Status Checks (Current Approach - RECOMMENDED)**

   - ✅ No elevated permissions needed
   - ✅ PR blocked until checks pass
   - ✅ Human review still required
   - ✅ Audit trail preserved
   - ✅ Works with branch protection

2. **Opt-in Auto-Merge (If Needed)**

   - Require explicit label (`auto-merge-approved`)
   - Require all checks passing
   - Require merge guard approval
   - Log all auto-merge operations
   - Notify team on auto-merge

3. **Never Auto-Merge Without Guards**
   - ❌ Always require validation passing
   - ❌ Always require AI review approval
   - ❌ Always require merge guard OK
   - ❌ Never skip status checks

### Recommended Implementation Strategy

#### Phase 1: Current (Status Checks) ✅

```yaml
# Block merge via status checks
# Human merges manually after review
permissions:
  contents: read
  pull-requests: write
  checks: write
  statuses: write
```

**Pros:**

- Safest approach
- Full audit trail
- Human in the loop
- Works with all protection rules

**Cons:**

- Requires manual merge
- Cannot fully automate

#### Phase 2: Opt-in Auto-Merge (Future)

```yaml
# Only if PR has 'auto-merge-approved' label
permissions:
  contents: write
  pull-requests: write
  checks: write
  statuses: write
```

**Pros:**

- Selective automation
- Still requires explicit approval
- Maintains safety guards

**Cons:**

- Needs elevated permissions
- Requires careful testing

#### Phase 3: Full Automation (Advanced)

```yaml
# Automatic merge after all checks pass
# Use PAT for cross-workflow triggers
env:
  GH_TOKEN: ${{ secrets.AUTO_MERGE_PAT }}
```

**Pros:**

- Fully automated workflow
- Can trigger downstream actions

**Cons:**

- Highest security risk
- Complex to configure safely
- May conflict with protection rules

### Current Implementation Decision

**CHOSEN: Phase 1 (Status Checks Only)**

**Rationale:**

1. ✅ Safest approach for initial deployment
2. ✅ No additional permissions needed
3. ✅ Works with all branch protection settings
4. ✅ Maintains human oversight
5. ✅ Full audit trail
6. ✅ Easy to rollback if issues

**Auto-merge can be added later if needed via:**

- Adding `contents: write` permission
- Implementing opt-in label mechanism
- Adding merge operation to workflow
- Extensive testing in non-production branch

### Opt-In Auto-Merge Implementation (If Needed)

Add this job to `ai-code-review.yml` **only if auto-merge is desired**:

```yaml
auto-merge:
  name: Auto-Merge (Opt-in)
  needs: ai-code-review
  if: |
    github.event_name == 'pull_request' &&
    contains(github.event.pull_request.labels.*.name, 'auto-merge-approved') &&
    needs.ai-code-review.outputs.merge_guard_status == 'approved'
  runs-on: ubuntu-latest
  permissions:
    contents: write
    pull-requests: write

  steps:
    - name: Verify all checks passed
      uses: actions/github-script@v7
      with:
        script: |
          const { data: checks } = await github.rest.checks.listForRef({
            owner: context.repo.owner,
            repo: context.repo.repo,
            ref: context.payload.pull_request.head.sha
          });

          const failedChecks = checks.check_runs.filter(
            check => check.conclusion !== 'success'
          );

          if (failedChecks.length > 0) {
            core.setFailed('Not all checks passed');
          }

    - name: Auto-merge PR
      uses: actions/github-script@v7
      with:
        script: |
          await github.rest.pulls.merge({
            owner: context.repo.owner,
            repo: context.repo.repo,
            pull_number: context.payload.pull_request.number,
            merge_method: 'squash',
            commit_title: `${context.payload.pull_request.title} (#${context.payload.pull_request.number})`,
            commit_message: 'Auto-merged after AI review approval and validation checks'
          });

          // Post merge notification
          await github.rest.issues.createComment({
            owner: context.repo.owner,
            repo: context.repo.repo,
            issue_number: context.payload.pull_request.number,
            body: '✅ Auto-merged after all checks passed and AI review approved'
          });
```

### Usage Instructions

#### Current (Manual Merge):

1. Create PR as usual
2. AI review runs automatically
3. Merge guard checks validation
4. Status check appears on PR
5. **Human merges manually** after review

#### Future (Opt-in Auto-Merge):

1. Create PR as usual
2. AI review runs automatically
3. If approved, add `auto-merge-approved` label
4. **Automatic merge** if all checks pass
5. Notification posted to PR

### Monitoring & Audit

#### What to Monitor:

- Number of auto-merged PRs
- Time from PR creation to merge
- False positive rate (auto-merge when shouldn't)
- False negative rate (block when should merge)

#### Audit Trail:

- All operations logged in GitHub Actions
- PR comments show AI review results
- Commit status shows merge guard decision
- Labels track auto-merge approvals

### Rollback Plan

If auto-merge causes issues:

1. **Immediate:** Remove `contents: write` permission
2. **Short-term:** Revert to status checks only
3. **Analysis:** Review failed merges
4. **Fix:** Update merge guard criteria
5. **Re-enable:** After thorough testing

### Conclusion

**Current implementation uses status checks (Phase 1) - safest and recommended.**

Auto-merge capability is **documented but not implemented** to maintain security and stability. Can be enabled later with proper testing and team approval.
