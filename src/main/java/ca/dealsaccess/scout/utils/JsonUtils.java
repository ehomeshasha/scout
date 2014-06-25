package ca.dealsaccess.scout.utils;

//import java.util.List;

import com.google.gson.Gson;

public class JsonUtils {
	
	private final static Gson gson = new Gson();
	
	public static void println(Object obj) {
		System.out.println(gson.toJson(obj));
	}
	
	public static void println(String objName, Object obj) {
		System.out.printf("%s: %s", objName, gson.toJson(obj));
		System.out.println();
	}
	
	public static String toJson(Object obj) {
		return gson.toJson(obj);
	}
	/*
	public void parseJSONArray() {
		String jsonArr = "[{'key1':'value1', 'key2':'value2'}, {'key1':'value1', 'key2':'value2'}]";
		Gson gson = new Gson();
		java.lang.reflect.Type type = new com.google.gson.reflect.TypeToken<List<JsonData>>(){}.getType();
		List<JsonData> fromJson = gson.fromJson(jsonArr, type);
		System.out.println(fromJson.toString());
	}

	// 解析JSONObject
	public void parseJSONObject() {
		String jsonObj = "{'key1':'value1', 'key2':'value2'}";
		Gson gson = new Gson();
		JsonData jsonData = gson.fromJson(jsonObj, JsonData.class);
		System.out.println(jsonData.toString());
	}

	class JsonData// 属性必须与json里面的key一致
	{
		String key1;
		String key2;

		@Override
		public String toString() {
			return "JSON1 [key1=" + key1 + ", key2=" + key2 + "]";
		}
	}
	*/
}
