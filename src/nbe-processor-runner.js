/*
 * A JS script that runs ./nbe-processor.rb with the specified arguments. 
 * Usage: 
 *   node nbe-processor-runner.js input-filename [-c]
 * Example:
 *   > node nbe-processor-runner.js resources/input.nbe
 *
 * If redis storage is needed to be cleaned, use the following command: 
 *  
 *   > node nbe-processor-runner.js resources/input.nbe -c     
 */
var execFile = require('child_process').execFile
var args = process.argv.slice(2);

console.log('Running nbe-processor.rb with the following arguments: ', args);

execFile('./nbe-processor.rb', args, function(error, stdout, stderr) {
  if(stdout) {
    console.log('stdout:\n', stdout);
  }
  
  if(stderr) {
    console.log('stderr:\n', stderr );
  }

  if (error) {
    console.log('error:\n', error);
  }
})