namespace boost {
  namespace serialization {


    template<class Archive>
    inline void serialize(Archive & ar, Vec4i& v, const unsigned int version) {

		size_t elemSize = 4;
		size_t elemType = v.type;

		ar & BOOST_SERIALIZATION_NVP(elemSize);
		ar & BOOST_SERIALIZATION_NVP(elemType); // element type.

		for (size_t dc = 0; dc < elemSize; dc++)
			ar & v[dc];

    }
  }
}