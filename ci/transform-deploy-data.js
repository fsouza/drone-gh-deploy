const DRONE_BUILD_LINK = process.env.DRONE_BUILD_LINK;

const readInput = () => {
  return new Promise((resolve, _reject) => {
    let inputData = '';

    process.stdin.on('data', (chunk) => {
      inputData += chunk;
    });

    process.stdin.on('end', () => {
      resolve(inputData);
    });
  });
};

readInput().then(data => {
  const repository = JSON.parse(data).data.repository;
  let deployment;

  for (const n of repository.deployments.edges) {
    const d = n.node;
    if (d.latestStatus.logUrl == DRONE_BUILD_LINK) {
      deployment = {
        id: d.id,
        logUrl: d.latestStatus.logUrl,
      };
      break;
    }
  }

  if (deployment) {
    process.stdout.write(JSON.stringify(deployment));
  }
});
