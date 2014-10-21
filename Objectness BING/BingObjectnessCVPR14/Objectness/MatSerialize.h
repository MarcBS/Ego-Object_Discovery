#include <boost/serialization/vector.hpp>

namespace boost {
  namespace serialization {


    template<class Archive>
    inline void serialize(Archive & ar, cv::Mat& m, const unsigned int version) {
      int cols = m.cols;
      int rows = m.rows;
      size_t elemSize = m.elemSize();
      size_t elemType = m.type();

      ar & BOOST_SERIALIZATION_NVP(cols);
      ar & BOOST_SERIALIZATION_NVP(rows);
      ar & BOOST_SERIALIZATION_NVP(elemSize);
      ar & BOOST_SERIALIZATION_NVP(elemType); // element type.

      if(m.type() != elemType || m.rows != rows || m.cols != cols) {
        m = cv::Mat(rows, cols, elemType, cv::Scalar(0));
      }

      size_t dataSize = cols * rows * elemSize;
      //cout << " datasize is " << dataSize;


      for (size_t dc = 0; dc < dataSize; dc++) {
        std::stringstream ss;
        ss << "elem_"<<dc;
        ar & boost::serialization::make_nvp(ss.str().c_str(), m.data[dc]);
      }

    }
  }
}