export const getCreators = (nfts) => {
  // for reduce function refer to mdn docs for understanding...

  const creators = nfts.reduce((creatorObject, nft) => {
    (creatorObject[nft.seller] = creatorObject[nft.seller] || []).push(nft);
    return creatorObject; // so that it can be used for next iteration
  }, {});

  return Object.entries(creators).map((creator) => {
    const seller = creator[0];
    const sum = creator[1].map((item) => Number(item.price)).reduce((prev, curr) => prev + curr, 0);
    return ({ seller, sum });
  });
};

// creators
// {
//   'A': [{}, {}]
//   'B': [{}]
//   'C': [{}]
// }

// Object.entries
// [[A, B, C], [[ {}, {}]]]

