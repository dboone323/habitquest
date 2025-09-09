module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [2, 'always', ['feat','fix','perf','refactor','ci','build','test','docs','chore','style','revert']],
    'type-case': [2, 'always', 'lower-case'],
    'scope-case': [1, 'always', 'lower-case'],
    'scope-empty': [1, 'never'],
    'subject-case': [2, 'never', ['sentence-case','start-case','pascal-case','upper-case']],
    'subject-empty': [2, 'never'],
    'subject-full-stop': [2, 'never', '.'],
    'header-max-length': [2, 'always', 100],
    'body-leading-blank': [1, 'always'],
    'footer-leading-blank': [1, 'always'],
    'body-max-line-length': [0],
    'footer-max-line-length': [0]
  }
};
