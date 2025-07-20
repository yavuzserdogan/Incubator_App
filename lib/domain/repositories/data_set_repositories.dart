import "package:incubator/domain/entities/data_set_entity.dart";

abstract class DataSetRepository {
  Future<List<DataSet>> getDataSet(String userId);

  Future<DataSet> getDataSetById(String dataSetId);

  Future<void> createDataSet(DataSet dataSet,String userId);

  Future<void> deleteDataSet(String id, String userId);
}