# BKT Parameters File Structure - Explained

## What are BKT Parameters?

BKT (Bayesian Knowledge Tracing) parameters are used by OATutor to track student mastery of skills (Knowledge Components or "KCs"). The system uses these parameters to determine if a student has mastered a concept and whether they're ready to move on.

## The File Renaming Issue

### The Problem

You may encounter errors mentioning `bktparam1` when running the content update workflow. This happens because **the system automatically renames bktParams files during deployment**.

### Where It Happens

The renaming occurs in two places:

1. **GitHub Actions Workflow** (`.github/workflows/deploy-content-staging.yml:56-62`):
```yaml
mv "OpenStax Content" "content-pool"
mkdir -p bkt-params
mv bktParams.json bkt-params/bktParams1.json
cp bkt-params/bktParams1.json bkt-params/bktParams2.json
```

2. **Local Update Script** (`src/tools/updateContent.sh:79-80`):
```bash
mv src/content-sources/oatutor/bktParams.json src/content-sources/oatutor/bkt-params/bktParams1.json
cp src/content-sources/oatutor/bkt-params/bktParams1.json src/content-sources/oatutor/bkt-params/bktParams2.json
```

### File Structure Transformation

**Before (from OATutor-Tooling content generation):**
```
src/content-sources/oatutor/
├── bktParams.json
└── OpenStax Content/
```

**After (automated transformation):**
```
src/content-sources/oatutor/
├── bkt-params/
│   ├── bktParams1.json
│   └── bktParams2.json
└── content-pool/
```

### Why Two Copies?

The system creates two copies for A/B testing:
- `bktParams1.json` = `defaultBKTParams.json` (control group)
- `bktParams2.json` = `experimentalBKTParams.json` (experimental group)

See `src/App.js:45-46`:
```javascript
import defaultBKTParams from "./content-sources/oatutor/bkt-params/defaultBKTParams.json";
import experimentalBKTParams from "./content-sources/oatutor/bkt-params/experimentalBKTParams.json";
```

## Expected Directory Structure

### For Content Staging

```
src/content-sources/oatutor/
├── bkt-params/
│   ├── defaultBKTParams.json     (used in production)
│   └── experimentalBKTParams.json (used for A/B testing)
├── content-pool/                  (renamed from "OpenStax Content")
│   ├── problem1/
│   ├── problem2/
│   └── ...
├── coursePlans.json
└── skillModel.json
```

### For Local Development

The application expects the bkt-params to be in the `bkt-params/` subdirectory with specific filenames:
- `defaultBKTParams.json` - Default parameters used for control group
- `experimentalBKTParams.json` - Experimental parameters for A/B testing

## How the System Uses These Files

1. **App.js imports both versions**:
```javascript
import defaultBKTParams from "./content-sources/oatutor/bkt-params/defaultBKTParams.json";
import experimentalBKTParams from "./content-sources/oatutor/bkt-params/experimentalBKTParams.json";
```

2. **Treatment assignment** (line 94):
```javascript
this.bktParams = this.getTreatmentObject(treatmentMapping.bktParams);
```

3. **A/B testing logic** determines which version each user gets based on their user ID:
```javascript
getTreatment = () => {
    return this.userID % 2;  // Returns 0 or 1
};
```

## What BKT Parameters Contain

BKT parameters typically include for each Knowledge Component (KC):
- **probMastery**: Probability that the student has mastered the skill
- **probSlip**: Probability of making a mistake despite mastery
- **probGuess**: Probability of getting the answer right by guessing
- **probLearn**: Probability of learning the skill after practice

Example structure:
```json
{
  "LinearEquations": {
    "probMastery": 0.3,
    "probSlip": 0.1,
    "probGuess": 0.25,
    "probLearn": 0.15
  },
  "QuadraticFormula": {
    "probMastery": 0.25,
    ...
  }
}
```

## Troubleshooting

### Error: Cannot find bktParams.json

**Cause**: The content generation created `bktParams.json` but the app expects `bkt-params/defaultBKTParams.json`

**Solution**: The automated workflow handles this. If running manually:
```bash
mkdir -p src/content-sources/oatutor/bkt-params
mv src/content-sources/oatutor/bktParams.json \
   src/content-sources/oatutor/bkt-params/defaultBKTParams.json
cp src/content-sources/oatutor/bkt-params/defaultBKTParams.json \
   src/content-sources/oatutor/bkt-params/experimentalBKTParams.json
```

### Error: Cannot find module 'defaultBKTParams.json'

**Cause**: The file structure doesn't match what App.js expects

**Solution**: Ensure files are in `src/content-sources/oatutor/bkt-params/` with exact names:
- `defaultBKTParams.json`
- `experimentalBKTParams.json`

### Content-Staging vs Local Development

- **Content-Staging branch**: Uses the automated workflow, files are renamed automatically
- **Local development**: You may need to manually create the correct structure
- **Production (gh-pages)**: Uses the preprocessed files from the build step

## Related Files

- `src/App.js` - Imports and uses BKT parameters
- `src/platform-logic/Platform.js` - Updates mastery based on student performance
- `src/components/problem-layout/Problem.js` - Applies BKT updates during problem solving
- `.github/workflows/deploy-content-staging.yml` - Automated content deployment
- `src/tools/updateContent.sh` - Local content update script
- `src/tools/preprocessProblemPool.js` - Preprocesses content before build

## Summary

The bktParams renaming is **intentional and automatic**. The content generation creates `bktParams.json`, which is then:
1. Moved to `bkt-params/` directory
2. Renamed to match the A/B testing structure
3. Duplicated to support experimental variations

This happens automatically in the deployment workflow, so you typically don't need to worry about it unless you're debugging content issues or running custom deployments.
