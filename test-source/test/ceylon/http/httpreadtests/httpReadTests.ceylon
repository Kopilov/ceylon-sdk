import ceylon.buffer.charset {
    utf8
}
import ceylon.uri { parse }
import ceylon.http.client { ClientRequest=Request }
import ceylon.http.server {
    Server, Status, 
    started, AsynchronousEndpoint, 
    Endpoint, Response, Request, 
    startsWith, Options, stopped, newServer,
    starting, stopping
}
import ceylon.test {
    assertEquals,
    test,
    beforeTest,
    afterTest
}
import ceylon.http.common { contentType, post}
import java.util.concurrent { Semaphore }
import java.lang { JString = String }
import ceylon.buffer { ByteBuffer }
import ceylon.http.server.websocket {
    WebSocketEndpoint
}

shared abstract class ServerTest() {

    variable Status? lastStatus = null;
    variable Boolean successfullyStarted = false;

    value startingLock = Semaphore(0);

    Boolean waitServerStarted() {
        startingLock.acquire();
        return successfullyStarted;
    }

    void notifyStatusUpdate(Status status) {
        if (status == started) {
            successfullyStarted = true;
            startingLock.release();
        } else if (status == stopped) {
            startingLock.release();
            if (exists last = lastStatus) {
                if (last == starting) {
                    throw AssertionError("Server failed to start.");
                } else if (last != stopping) {
                    throw AssertionError("Unexpected server stop.");
                }
            }
        }
    }
    
    variable Server? server = null;
    
    shared formal {<Endpoint|AsynchronousEndpoint|WebSocketEndpoint>+} endpoints;
    
    beforeTest
    shared void startServerBeforeTest() {
        
        value server = newServer(endpoints);
        server.addListener(notifyStatusUpdate);
        
        server.startInBackground {
            serverOptions = Options {
                defaultCharset = utf8;
                workerTaskMaxThreads=2;
            };
        };
        value successfullyStarted = waitServerStarted();
        if (!successfullyStarted) {
            throw AssertionError("Server failed to start.");
        }
        this.server = server;
    }
    
    afterTest
    shared void stopServerAfterTest() {
        if (exists s=server) {
            s.stop();
        }
    }
}

shared class TestServer() extends ServerTest() {
    shared actual {<Endpoint|AsynchronousEndpoint>+} endpoints => {
        Endpoint {
            void service(Request request, Response response) {
                ByteBuffer dataRaw = ByteBuffer(request.readBinary());
                String data = JString(dataRaw.array, request.requestCharset).string;
                response.addHeader(contentType("text/plain", utf8));
                response.writeString(data);
            }
            path = startsWith("/printReadBinaryBody");
        },
        Endpoint {
            void service(Request request, Response response) {
                String data = request.read();
                response.addHeader(contentType("text/plain", utf8));
                response.writeString(data);
            }
            path = startsWith("/printReadStringBody");
        }
    };
    
    shared test void printReadBinaryBody() {        
        value readRequest = ClientRequest(parse("http://localhost:8080/printReadBinaryBody"), post);
        String textToPost = "Test single sring body";
        readRequest.setHeader("Content-Type", "text/plain; charset=utf8");
        readRequest.data = textToPost;
        value readResponse = readRequest.execute();
        assertEquals(readResponse.contents, textToPost);
    }
    shared test void printReadStringBody() {        
        value readRequest = ClientRequest(parse("http://localhost:8080/printReadStringBody"), post);
        String textToPost = "Test single sring body";
        readRequest.setHeader("Content-Type", "text/plain; charset=utf8");
        readRequest.data = textToPost;
        value readResponse = readRequest.execute();
        assertEquals(readResponse.contents, textToPost);
    }
}
