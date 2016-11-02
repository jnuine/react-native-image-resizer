import { NativeModules } from 'react-native';
const { ImageResizer } = NativeModules;

export default {
  saveImage: (path, width, height, quality) => {
    return new Promise((resolve, reject) => {
      ImageResizer.saveImage(path, width, height, quality, (err, resizedPath, { width, height }) => {
        if (err) {
          return reject(err);
        }

        resolve({
          path: resizedPath,
          width,
          height,
        });
      });
    });
  },
};
